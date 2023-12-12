#!/bin/bash

SKYPE_PROFILE="/var/lib/snapd/apparmor/profiles/snap.skype.skype"
BACKUP_DIR="./backup/"
ADD_FILE="snap.skype.skype.add"

if [[ ! -d $BACKUP_DIR ]]; then
  echo "Making Backup Dir"
  mkdir $BACKUP_DIR
fi

NOW=$(date +%Y%m%d%H%M%S)

echo "Backing up $SKYPE_PROFILE to $BACKUP_DIR"

if ! cp "$SKYPE_PROFILE" "$BACKUP_DIR/snap.skype.skype.$NOW"; then
  echo "ERROR: cannot backup $SKYPE_PROFILE"
  exit 1
fi

echo "Patching $SKYPE_PROFILE"

if ! sudo patch "$SKYPE_PROFILE" snap.skype.skype.diff; then
  echo "ERROR: Can not patch. Please do so manually, then run apparmor_apply"
  exit 1
fi

echo "Updating apparmor_parser"
if ! sudo apparmor_parser -r "$SKYPE_PROFILE"; then
  echo "ERROR: Can not apply updates. Exiting"
  exit 1
fi

echo "Successfully applied patch and updated apparmor"
exit 0
