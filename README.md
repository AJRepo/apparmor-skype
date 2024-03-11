# apparmor-skype
Apparmor profile for skypeforlinux

Skypeforlinux installed via snap installs an apparmor file at 
/var/lib/snapd/apparmor/profiles/snap.skype.skype

With the standard installation one gets errors like

 kernel: [50771.953709] audit: type=1400 audit(1697573764.787:1717889): apparmor="DENIED" operation="open" class="file" profile="snap.skype.skype" name="/sys/devices/LNXSYSTM:00/LNXSYBUS:00/ACPI0003:00/power_supply/AC/online" pid=40326 comm="skypeforlinux" requested_mask="r" denied_mask="r" fsuid=1000 ouid=0

In theory, one can modify a file in the directory /etc/apparmor.d/local/ to add modifications and not edit the snap-provided file, however that didn't seem to fix
the errors. 

This repository is for overriding the snap provided file and instructions.

# Installation 

0. Backup your old apparmor profile in case something goes wrong

  `sudo cp  /var/lib/snapd/apparmor/profiles/snap.skype.skype /tmp/`

1. Update the file `/var/lib/snapd/apparmor/profiles/snap.skype.skype` and put the code from snap.skype.skype.add
   right above the closing curly bracket`}` e.g.
```
  /sys/devices/*/*/*/*/*/online r,
  /sys/devices/*/*/*/power_supply/* r,
  /etc/issue r,
  ...
```

See the file snap.skype.skype.add for the text to add.
See the file snap.skype.skype.diff for a git diff

You can update with the command: 
`patch /var/lib/snapd/apparmor/profiles/snap.skype.skype snap.skype.skype.diff`

2. Use apparmor_parser to replace (-r flag) that profile 

  `sudo apparmor_parser -r /var/lib/snapd/apparmor/profiles/snap.skype.skype`

This should be sufficient. If not then restart the apparmor service

3. `sudo systemctl restart apparmor.service`

Tested with Skype versions (from `snap list skype`)

```
Name   Version      Rev  Tracking       Publisher  Notes
skype  8.106.0.210  305  latest/stable  skype✓     -
skype  8.106.0.212  306  latest/stable  skype✓     -
skype  8.107.0.215  309  latest/stable  skype✓     -
skype  8.108.0.205  311  latest/stable  skype✓     -
skype  8.110.0.211  317  latest/stable  skype✓     -
skype  8.110.0.215  319  latest/stable  skype✓     -
skype  8.110.0.218  320  latest/stable  skype✓     -
skype  8.111.0.607  323  latest/stable  skype✓     -
skype  8.113.0.210  330  latest/stable  skype✓     -
skype  8.114.0.214  333  latest/stable  skype✓     -


```
# Bash Scripts for Installation

There are two scripts to do steps 0-3 above.

* The first is named `update_with_diff.sh`.  This uses the file
`snap.skype.skype.diff` to do the update as above.

* The second is named `update_with_add.sh`. This 
looks for a '}' as the last line of the skype profile file and then replaces it with the 
contents of the file `snap.skype.skype.add` + '}'

At some point these two scripts might be merged or one of them deprecated. 

Both of these scripts should be considered to be in beta status. 

# Recovery
If you've done something wrong with /var/lib/snapd/apparmor/profiles (e.g. didn't backup first and now skype won't start)
then you can get back with your old data with the following

1. Create a snapshot of your existing data (includes your skype username, chats, etc.)
```
sudo snap save skype
```
You'll get something like
```
Set  Snap   Age    Version      Rev  Size    Notes
9    skype  7.58s  8.106.0.212  306  56.5MB  -
```
Note that `Set` number you get above (in this case it is = 9)

2. Remove skype without any other flags and restore the snapshot you made. 

```
sudo snap remove skype
sudo snap install skype
sudo snap restore XXXX
  where XXXX is the number you saw given with the "save" command
```

Technically `snap remove skype` is supposed to create a save point also, but I prefer
to create one manually just to be sure. 

3. (Optional) `forget` the snapshot you created.
   
you can get a list of your snapshots with `snap saved` and in the above case (Set=9)
you can delete it with 

`snap forget 9`

# Ongoing tests
See the file `check_skype_profile` which is a bash script to see if a new version of skype has overwritten
the apparmor code. It calls `notify-send` which will not work unless it can attach to the dbus session and 
DISPLAY of the person in the GUI. So, note the comments below about making sure you have the user_name and
the user_id accurate in the crontab entry. 

When adding it to your cron, make sure you set the path correctly. Example: 
#Run every hour at 14 minutes past the hour
#Replace MY_USER_NAME and MY_USER_ID as appropriate
14 * * * * MY_USER_NAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/MY_USER_ID/bus /PATH/TO/apparmor-skype/check_skype_profile


Copyright AJRepo 2023
(Afan Ottenheimer)
