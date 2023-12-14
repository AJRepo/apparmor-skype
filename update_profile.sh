#!/bin/bash

SKYPE_PROFILE="/var/lib/snapd/apparmor/profiles/snap.skype.skype"
BACKUP_DIR="./backup/"

if [[ ! -d $BACKUP_DIR ]]; then
  echo "Making Backup Dir"
  mkdir $BACKUP_DIR
fi

NOW=$(date +%Y%m%d%H%M%S)

if grep -q AJRepo "$SKYPE_PROFILE"; then
  echo "Checking existing profile and found already applied, exiting."
  exit 1
fi

echo "Backing up $SKYPE_PROFILE to $BACKUP_DIR"

if ! cp "$SKYPE_PROFILE" "$BACKUP_DIR/snap.skype.skype.$NOW"; then
  echo "ERROR: cannot backup $SKYPE_PROFILE"
  exit 1
fi

echo "Patching $SKYPE_PROFILE"

if ! sudo patch "$SKYPE_PROFILE" snap.skype.skype.diff; then
  echo "ERROR: Can not patch. Please do so manually, then run apparmor_parser"
  exit 1
fi

echo "Updating apparmor_parser"
if ! sudo apparmor_parser -r "$SKYPE_PROFILE"; then
  echo "ERROR: apparmor_parser did not run successfully. Exiting"
  exit 1
fi

echo "Successfully applied patch and updated apparmor. To see changes run:"
echo "git diff $BACKUP_DIR/snap.skype.skype.$NOW $SKYPE_PROFILE"
exit 0
