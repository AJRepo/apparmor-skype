# apparmor-skype
Apparmor profile for skypeforlinux

Skypeforlinux installed via snap installs an apparmor file at 
/var/lib/snapd/apparmor/profiles/snap.skype.skype

With the standard installation one gets errors like

 kernel: [50771.953709] audit: type=1400 audit(1697573764.787:1717889): apparmor="DENIED" operation="open" class="file" profile="snap.skype.skype" name="/sys/devices/LNXSYSTM:00/LNXSYBUS:00/ACPI0003:00/power_supply/AC/online" pid=40326 comm="skypeforlinux" requested_mask="r" denied_mask="r" fsuid=1000 ouid=0

In theory, one can modify a file in the directory /etc/apparmor.d/local/ to add modifications and not edit the snap-provided file, however that didn't seem to fix
the errors. 

This repository is for overriding the snap provided file and instructions.

0. Backup your old apparmor profile in case something goes wrong

  `sudp cp  /var/lib/snapd/apparmor/profiles/snap.skype.skype /tmp/`

1. Edit the file `/var/lib/snapd/apparmor/profiles/snap.skype.skype` and put the following code
   right above the closing curly bracket`}`
```
  /sys/devices/*/*/*/*/*/online r,
  /sys/devices/*/*/*/power_supply/* r,
  /etc/issue r,
```

See the file snap.skype.skype.add for the text to add.
See the file snap.skype.skype.diff for a git diff

2. Get into the directory where you put that apparmor file. 

   `cd /var/lib/snapd/apparmor/profiles/`
3. Replace (-r flag) that profile 

  `sudo apparmor_parser -r snap.skype.skype`

This should be sufficient. If not then restart the apparmor service

4. `sudo systemctl restart apparmor.service`

Tested with Skype versions 8.106.0.210, 8.106.0.212 from `snap list skype`

```
Name                               Version                     Rev    Tracking       Publisher      Notes
skype                              8.106.0.210                 305    latest/stable  skype✓         -
skype                              8.106.0.212                 306    latest/stable  skype✓         -
```
