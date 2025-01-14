# apparmor-skype

Apparmor profile for skypeforlinux

Skypeforlinux installed via snap installs an apparmor file at
/var/lib/snapd/apparmor/profiles/snap.skype.skype

With the standard installation one gets errors like

`kernel: [50771.953709] audit: type=1400 audit(1697573764.787:1717889): apparmor="DENIED"
 operation="open" class="file"
 profile="snap.skype.skype" name="/sys/devices/LNXSYSTM:00/LNXSYBUS:00/ACPI0003:00/power_supply/AC/online"
 pid=40326 comm="skypeforlinux" requested_mask="r" denied_mask="r" fsuid=1000 ouid=0
`

In theory, one can modify a file in the directory /etc/apparmor.d/local/ to add
modifications and not edit the snap-provided file, however that didn't seem to fix
the errors.

This repository is for overriding the snap provided file and instructions.

## Installation

1. Backup your old apparmor profile in case something goes wrong

      `sudo cp  /var/lib/snapd/apparmor/profiles/snap.skype.skype /tmp/`

1. Update the file `/var/lib/snapd/apparmor/profiles/snap.skype.skype` and put the
   code from snap.skype.skype.add
   right above the closing curly bracket`}` e.g.

   ```bash
    /sys/devices/*/*/*/*/*/online r,
    /sys/devices/*/*/*/power_supply/* r,
    /etc/issue r,
    ...
   ```

   See the file snap.skype.skype.add for the text to add.
   See the file snap.skype.skype.diff for a git diff

   You can update with the command:
       `patch /var/lib/snapd/apparmor/profiles/snap.skype.skype snap.skype.skype.diff`

1. Use `apparmor_parser` to replace (-r flag) that profile

     `sudo apparmor_parser -r /var/lib/snapd/apparmor/profiles/snap.skype.skype`

    This should be sufficient. If not then restart the apparmor service (step 3 below)

1. (optional) Restart apparmor

      `sudo systemctl restart apparmor.service`

1. (optional) Setup crontab monitoring for snap skype updates.

   See "Monitoring for Skype Profile Changes" below.

## Bash Scripts for Installation

There are two scripts to do steps 0-3 above.

* The first is named `update_with_diff.sh`.
  This uses the file `snap.skype.skype.diff` to do the update as above.

* The second is named `update_with_add.sh`. This
  looks for a '}' as the last line of the skype profile file and
  then replaces it with the contents of the file `snap.skype.skype.add` + '}'

At some point these two scripts might be merged or one of them deprecated.

Both of these scripts should be considered to be in RC-1 status.

## Recovery

If you've done something wrong with /var/lib/snapd/apparmor/profiles
 (e.g. didn't backup first and now skype won't start)
 then you can get back with your old data with the following

1. Create a snapshot of the existing data (includes the skype username, chats, etc.)

```bash
sudo snap save skype
```

You'll get something like

```bash
Set  Snap   Age    Version      Rev  Size    Notes
9    skype  7.58s  8.106.0.212  306  56.5MB  -
```

Note that `Set` number you get above (in this case it is = 9)

Note that you can see the list of saved snapshots with

```bash
sudo snap saved skype
```

1. Remove skype without any other flags and restore the snapshot you made.

```bash
sudo snap remove skype
sudo snap install skype
sudo snap restore XXXX
  where XXXX is the number you saw given with the "save" command
```

Technically `snap remove skype` is supposed to create a save point also, but I prefer
to create one manually just to be sure.

1. (Optional) `forget` the snapshot you created.

you can get a list of your snapshots with `snap saved` and in the above case (Set=9)
you can delete it with

`snap forget 9`

## Monitoring for Skype Profile Changes

For some reason, the skype apparmor setting will revert to the default. If this happens
then you will again have too many reports in your systlog.

The file `check_skype_profile` is a bash script
which checks if the apparmor script has
revereted to the default.

This script calls `notify-send` which will not work unless it can attach to the
dbus session and DISPLAY of the person in the GUI. So, note that you want it to
run as the user who will be logged into the system and not root.

(e.g. In the below crontab, replace `MY_USER_NAME` and `MY_USER_ID` respectively)

When adding it to your cron, make sure you set the path correctly. Example:

```bash
#Cron.d script
#Run every hour at 14 minutes past the hour
#Replace MY_USER_NAME and MY_USER_ID as appropriate
14 * * * * MY_USER_NAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/MY_USER_ID/bus /PATH/TO/apparmor-skype/check_skype_profile
```

## Compatibility Notes: parser errors

Some versions of Linux have an apparmor issue using the default skype apparmor
configuration. If you are running that verison of Linux, you can get
the following error:

`AppArmor parser error for /var/lib/snapd/apparmor/profiles/snap.skype.skype
 in profile /var/lib/snapd/apparmor/profiles/snap.skype.skype at line 2558:
 syntax error, unexpected TOK_END_OF_RULE, expecting TOK_MODE`

This issue is related to snap's apparmor config. Specifically it is this
line in that file:

```bash
`userns,`
```

Changing that line to `userns w,` or commenting it out
makes the apparmor error go away. Which is best? It is unclear to me as there
is limited documentation about `userns` in apparmor documentation.

The apparmor documentation seems to suggest that `allow userns create,` is the recommended replacement.

See: <https://gitlab.com/apparmor/apparmor/-/wikis/unprivileged_userns_restriction>
for more information.

## Tests

Tested with Skype versions (from `snap list skype`)

```bash
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
skype  8.115.0.215  336  latest/stable  skype✓     -
skype  8.115.0.217  337  latest/stable  skype✓     -
skype  8.116.0.213  340  latest/stable  skype✓     -
skype  8.117.0.202  342  latest/stable  skype✓     -
skype  8.118.0.205  345  latest/stable  skype✓     -
skype  8.119.0.201  348  latest/stable  skype✓     -
skype  8.124.0.204  351  latest/stable  skype✓     -
skype  8.125.0.201  353  latest/stable  skype✓     -
skype  8.126.0.208  357  latest/stable  skype✓     -
skype  8.127.0.200  359  latest/stable  skype✓     -
skype  8.128.0.207  361  latest/stable  skype✓     -
skype  8.129.0.202  365  latest/stable  skype✓     -
skype  8.130.0.205  368  latest/stable  skype✓     -
skype  8.131.0.202  370  latest/stable  skype✓     -
skype  8.133.0.202  375  latest/stable  skype✓     -
skype  8.134.0.202  378  latest/stable  skype✓     -
```

Copyright AJRepo 2023
(Afan Ottenheimer)
