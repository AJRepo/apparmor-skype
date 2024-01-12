#!/bin/bash

SKYPE_PROFILE="/var/lib/snapd/apparmor/profiles/snap.skype.skype"
SKYPE_TMP="/tmp/skype.tmp"
BACKUP_DIR="./backup/"

if [[ ! -d $BACKUP_DIR ]]; then
  echo "Making Backup Dir"
  mkdir $BACKUP_DIR
fi

if [[ -f $SKYPE_TMP ]]; then
  echo "TMP FILE $SKYPE_TMP exists. Exiting"
  exit 1
fi

NOW=$(date +%Y%m%d%H%M%S)

echo "Backing up $SKYPE_PROFILE to $BACKUP_DIR"

if ! cp "$SKYPE_PROFILE" "$BACKUP_DIR/snap.skype.skype.$NOW"; then
  echo "ERROR: cannot backup $SKYPE_PROFILE"
  exit 1
fi

LAST_LINE=$(tail -1 $SKYPE_PROFILE)

echo "This does not check if this has already been run once."
echo "Use at your own risk or check $SKYPE_PROFILE first"
read -rp "Press Ctrl-C to stop"

if [[ $LAST_LINE != "}" ]]; then 
  echo "Last line is not '}', exiting"
  exit 1
fi

head --lines=-1 $SKYPE_PROFILE | cat - snap.skype.skype.add > $SKYPE_TMP
echo "}" >> $SKYPE_TMP

if ! sudo mv "$SKYPE_TMP" "$SKYPE_PROFILE"; then
  echo "ERROR unable to move $SKYPE_TMP to $SKYPE_PROFILE. Exiting"
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
