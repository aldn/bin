#!/bin/sh

#qemu-img create -f qcow2 system.img 15G

iso_path="/Users/sasha/Downloads"
install_iso="$iso_path/ru_windows_7_ultimate_with_sp1_x64_dvd_u_677391_20111224.iso"
driver_iso="$iso_path/virtio-win-0.1.160.iso"

options_kvm=""
options_install=""

if [ "`uname`" == "Linux" ]; then
    options_kvm="-cpu host -enable-kvm"
fi

if [ "$1" == "install" ]; then
    options_install="-boot d -drive file=$install_iso,media=cdrom -drive file=$driver_iso,media=cdrom"
fi

exec qemu-system-x86_64 \
        -drive file=system.img,if=virtio \
        -net nic -net user,hostname=windowsvm \
        -m 4G \
        -monitor stdio \
        -name "Windows" \
        $options_kvm \
        $options_install
