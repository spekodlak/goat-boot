PREREQUISITE: Extract UBCD ISO image to your hard disk, or mount the ISO image using loopback.
You cannot run syslinux from the USB thumb drive because files cannot be marked as executable
on a FAT32 partition.

To put UBCD on a USB thumb drive, your thumb drive needs to be partitioned in FAT16 or FAT32.

First we need to know on which device your USB thumb drive is listed in /dev/.
Afterwards we can format it and copy the necessary files.

1. Remove your USB thumb drive from your USB port if you already attached it.

2. Run one of the following command:
      A) fdisk -l
            It will list all drives. Look at the size to determine which one is your
            USB thumb drive. It can be that you need root rights to see the drives.

  	  B) dmesg | tail
            This will display something like the following, if you have just put in the
            USB thumb drive.
              [38350.743408] sd 9:0:0:0: [sdb] 4028416 512-byte hardware sectors (2063 MB)
              [38350.744272] sd 9:0:0:0: [sdb] Write Protect is off
              [38350.744284] sd 9:0:0:0: [sdb] Mode Sense: 23 00 00 00
              [38350.744291] sd 9:0:0:0: [sdb] Assuming drive cache: write through
              [38350.747289] sd 9:0:0:0: [sdb] 4028416 512-byte hardware sectors (2063 MB)
              [38350.748267] sd 9:0:0:0: [sdb] Write Protect is off
              [38350.748284] sd 9:0:0:0: [sdb] Mode Sense: 23 00 00 00
              [38350.748289] sd 9:0:0:0: [sdb] Assuming drive cache: write through
              [38350.748305]  sdb: sdb1
              [38350.749432] sd 9:0:0:0: [sdb] Attached SCSI removable disk

            In this case, my USB thumb drive is /dev/sdc.

      C) df -h
            You can use this only when the USB thumb drive is automounted by your
            distribution or when you mount it yourself.
            It will list all mounted filesystems. You have to find and know the size
            of the partitions which are already on the USB thumb drive.

               /dev/sdb1             2,0G  1,9G   87M  96% /media/NANO

            In my case, my USB thumb drive is /dev/sdb (discard the number on the end).

3. If you have found on which device in /dev/, your USB thumb drive is, you can partition it.

   WARNING: backup all files that you want to preserve to another drive.
   WARNING: This process will delete any information that is currently stored on the USB key.
            Proceed with caution!

      A) First, we delete all old partitions that remain on the USB key.

         1. Open a terminal and type sudo su
         2. Type umount /dev/sdX to unmount your USB thumb drive
            (replace X with the right letter for your device. BE CAREFUL)
         3. Type fdisk /dev/sdX (replacing X with your drive letter)
         4. Type d to proceed to delete a partition
         5. Type 1 to select the 1st partition and press enter
         6. Type d to proceed to delete another partition
            (fdisk should automatically select the second partition)

      B) Next, we need to create the new partition.

         1. Type n to make a new partition
         2. Type p to make this partition primary and press enter
         3. Type 1 to make this the first partition and then press enter
         4. Type a, then 1, to make the first primary partition active or bootable.
         5. Press enter to accept the default first cylinder
         6. Press enter again to accept the default last cylinder
         7. Press t to change the partition ID:
              If you want to format your USB thumb drive with FAT16, use:
                 'W95 FAT16 (LBA)' ==> press e
              If you want to format your USB thumb drive with FAT32
              (needed for partitions, larger than 2 GB, use:
                 'W95 FAT32 (LBA)'  ==> press c
         8. Type w to write the new partition information to the USB key


      C) Now, we need to create the fat filesystem.

         1. If you have chosen to format your USB thumb drive in FAT16
            ('W95 FAT16 (LBA)' in previous step), use:

               mkfs.vfat -F 16 /dev/sdX1 (replacing X with your USB key drive letter)

         2. If you have chosen to format your USB thumb drive in FAT32
            ('W95 FAT32 (LBA)' in previous step), use:

               mkfs.vfat -F 32 /dev/sdX1 (replacing X with your USB key drive letter)

4. Now, we write the syslinux mbr to the USB drive.
   The mbr.bin file is located in ./ubcd/tools/linux/ubcd2usb/ of the extracted UBCD iso.

     dd if=mbr.bin of=/dev/sdX (replacing X with your USB key drive letter)

5. Mount the partition of your USB drive
   You can use the GUI mounting utility of your distribution.
   If your distribution mounts USB drives automatically, you can remove and replug your USB thumb drive.

6. Copy all files of the extracted UBCD iso to your USB thumb drive.

7. Install syslinux to the partition of your USB thumb drive.

   Unmount the target device.

   Make sure that ./ubcd/tools/linux/ubcd2usb/syslinux is executable, if not, run:

     chmod a+x ./ubcd/tools/linux/ubcd2usb/syslinux (adapt the path if necessary)
	 
   If it is executable, run:

     sudo ./ubcd/tools/linux/ubcd2usb/syslinux --install -s -d /boot/syslinux /dev/sdX1
	 (replacing X with your USB key drive letter)
	 
   NOTE: If you are running x64 kernel instead of x86, you will need to use syslinux64
   instead of syslinux. Alternatively, install syslinux using the package manager supported
   by your distribution. The last resort is to download the syslinux tarball and compile
   from scratch.

8. Now you can boot UBCD from your USB drive, if your BIOS supports it of course.

Additional resources:

- http://nlug.ml1.co.uk/2012/04/installing-the-ultimate-boot-cd-to-usb-memory-stick/2512
