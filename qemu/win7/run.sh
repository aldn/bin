#!/bin/sh
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

QEMU_BIN="qemu-system-x86_64"

# create logfile /tmp/qemu.log
#ARGS+="-d guest_errors "

#ARGS+="-name Windows "

# booting from CD/installing
INSTALL=0

# CPU:
ARGS+="-enable-kvm "
ARGS+="-cpu host "
ARGS+="-smp cores=2 "

# Memory:
ARGS+="-m 6G "

# Disks:
#   Main hard disk
# qemu-img create -f qcow2 root.qcow2 15G
ARGS+="-drive file=Windows7.qcow2,if=virtio "

if [ "$INSTALL" != "0" ];then
    ARGS+="-boot d -drive file=/mnt/nas/depot/install/os/win/Win7Pro_x86_x64_2016.iso,media=cdrom "
    #ARGS+="-boot d -drive file=/mnt/nas/depot/install/os/win/ru_windows_7_ultimate_with_sp1_x64_dvd_u_677391_20111224.iso,media=cdrom "
    ARGS+="-drive file=virtio-win.iso,media=cdrom "
    ARGS+="-drive file=spice-guest-tools-0.100.iso,media=cdrom "
fi

# Network:
#   Note: To access internal SMB share go to \\10.0.2.4\qemu
#ARGS+="-net nic,model=virtio -net tap,ifname=tap0,script=no,downscript=no "
ARGS+="-net nic,model=virtio -net user,smb=/mnt/hd/depot/shared "

# Devices:
#ARGS+="-vga std "
ARGS+="-vga qxl -spice port=5930,disable-ticketing "
ARGS+="-device virtio-serial "
ARGS+="-device virtserialport,chardev=vdagent,name=com.redhat.spice.0 "
ARGS+="-chardev spicevmc,id=vdagent,name=vdagent "
ARGS+="-soundhw hda "
ARGS+="-balloon virtio "
ARGS+="-usbdevice tablet "
ARGS+="-localtime "

# Monitor
SOCKETPATH="$SCRIPTPATH/monitor"
ARGS+="-monitor unix:$SOCKETPATH,server,nowait "

# Run detached from the terminal
ARGS+="-daemonize "

ARGS+="$@"

#############################

if [ -z `pgrep $QEMU_BIN` ]; then
    $QEMU_BIN $ARGS
fi


spicy -h 127.0.0.1 -p 5930 &

