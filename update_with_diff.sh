#!/bin/bash
# Copyright 2024 AJRepo

SKYPE_PROFILE="/var/lib/snapd/apparmor/profiles/snap.skype.skype"
BACKUP_DIR="./backup/"

if [[ ! -f $SKYPE_PROFILE ]]; then
  echo "Can't find installed skype profile at $SKYPE_PROFILE"
  echo "Is skype installed? Exiting"
  exit 1
fi

if [[ ! -d $BACKUP_DIR ]]; then
  echo "Making Backup Dir"
  mkdir $BACKUP_DIR
fi

NOW=$(date +%Y%m%d%H%M%S)

#Check if this has already been applied once
echo "Checking existing profile $SKYPE_PROFILE...."
if grep -q AJRepo "$SKYPE_PROFILE"; then
  echo "    found AJRepo code already applied, exiting."
  exit 1
else
  echo "    found skype profile in default state"
  echo ""
  echo "About to make backup and then apply update"
  read -rp "Press Ctrl-C to stop. Press 'enter' key to continue .... "
fi

echo "Backing up $SKYPE_PROFILE to $BACKUP_DIR/snap.skype.skype.$NOW"

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
  echo "ERROR: apparmor_parser did not run successfully. Testing potential cause."
  #Note: Ubuntu introducted access to Restricted unprivileged user namespaces
  ## https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces
  # if you have Debian 12 or earlier versions of Ubuntu this will genrerate an error
  echo "---Check potential userns error in line 2574"
  if grep -qE "^userns," "$SKYPE_PROFILE"; then
    echo "   This version of Ubuntu or Debian doesn't support userns"
    echo "   See https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces"
    echo "   Comment out 'userns,' on line 2574 of $SKYPE_PROFILE and rerun "
    echo "       sudo apparmor_parser -r $SKYPE_PROFILE"
    echo    "Exiting"
  fi
  exit 1
fi

echo "Successfully applied patch and updated apparmor. To see changes run:"
echo "git diff $BACKUP_DIR/snap.skype.skype.$NOW $SKYPE_PROFILE"
exit 0
