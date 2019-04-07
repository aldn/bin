#!/bin/sh

EXE="qemu-system-x86_64"

#############################
ARGS+="-name Windows "
ARGS+="-enable-kvm "
ARGS+="-cpu host "
ARGS+="-smp cores=2 "
ARGS+="-m 350M "
ARGS+="-balloon virtio "
ARGS+="-drive file=xp.qcow2,if=virtio "
#ARGS+="-drive file=fake.qcow2,if=virtio "
#ARGS+="-net nic,model=virtio -net tap,ifname=tap0,script=no,downscript=no "
ARGS+="-net nic,model=virtio -net user,smb=/mnt/hd/depot/shared "
#ARGS+="-vga std "
ARGS+="-vga qxl -spice port=5930,disable-ticketing "
ARGS+="-device virtio-serial "
ARGS+="-chardev spicevmc,id=vdagent,name=vdagent "
ARGS+="-device virtserialport,chardev=vdagent,name=com.redhat.spice.0 "
ARGS+="-soundhw ac97 "
ARGS+="-localtime "


# only for booting from CD/installing
#ARGS+="-boot d -drive file=/mnt/nas/depot/install/os/win/xp/01/GRTMPVOL_RU_Y1406.iso,media=cdrom "

# RedHat virtio drivers
ARGS+="-drive file=virtio-win.iso,media=cdrom "

ARGS+="-daemonize "

ARGS+="$@"

#############################


$EXE $ARGS
exec spicy -h 127.0.0.1 -p 5930

