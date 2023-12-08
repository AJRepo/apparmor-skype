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

1. Edit the file `/var/lib/snapd/apparmor/profiles/snap.skype.skype` and put the code from snap.skype.skype.add
   right above the closing curly bracket`}` e.g.
```
  /sys/devices/*/*/*/*/*/online r,
  /sys/devices/*/*/*/power_supply/* r,
  /etc/issue r,
  ...
```

See the file snap.skype.skype.add for the text to add.
See the file snap.skype.skype.diff for a git diff

2. Get into the directory where you put that apparmor file. 

   `cd /var/lib/snapd/apparmor/profiles/`
3. Replace (-r flag) that profile 

  `sudo apparmor_parser -r /var/lib/snapd/apparmor/profiles/snap.skype.skype`

This should be sufficient. If not then restart the apparmor service

4. `sudo systemctl restart apparmor.service`

Tested with Skype versions (from `snap list skype`)

```
Name    Version        Rev    Tracking       Publisher      Notes
skype   8.106.0.210    305    latest/stable  skype✓         -
skype   8.106.0.212    306    latest/stable  skype✓         -
skype   8.107.0.215    309    latest/stable  skype✓         -
skype   8.108.0.205    311    latest/stable  skype✓         -
skype   8.110.0.211    317    latest/stable  skype✓         -


```

# Recovery
If you've done something wrong with /var/lib/snapd/apparmor/profiles (e.g. didn't backup first and now skype won't start)
then you can get back with your old data with the following

```
sudo snap save skype
```
You'll get something like
```
Set  Snap   Age    Version      Rev  Size    Notes
9    skype  7.58s  8.106.0.212  306  56.5MB  -
```
Note that Set number you get (in this case it is = 9)

```
sudo snap remove skype
sudo snap install skype
sudo snap restore XXXX
  where XXXX is the number you saw given with the "save" command
```

Technically `snap remove skype` is supposed to create a save point also, but I prefer
to create one manually just to be sure. 

you can get a list of your snapshots with `snap saved`
