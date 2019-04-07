
# As of Yosemite (OS X 10.10), we need to tell KVM to ignore
# unhandled MSR accesses (During boot, Yosemite attempts to
# read from MSR 0x199, which is related to CPU frequency
# scaling, and is clearly not applicable to a VM guest):
#
#echo 1 > /sys/module/kvm/parameters/ignore_msrs


    #-device isa-applesmc,osk="insert-real-64-char-OSK-string-here" \
qemu-system-x86_64 \
    -enable-kvm \
    -m 4096 \
    -cpu core2duo,vendor=GenuineIntel \
    -smp 4,cores=2 \
    -machine q35 \
    -usb -device usb-kbd -device usb-mouse \
    -kernel ./enoch_rev2839_boot \
    -smbios type=2 \
    -device ide-drive,bus=ide.2,drive=MacHDD \
    -drive id=MacHDD,if=none,file=./OSXElCapitan.img \
    -device ide-drive,bus=ide.3,drive=TransferHDD \
    -drive id=TransferHDD,if=none,file=./TransferDisk.img \
    -netdev user,id=hub0port0 \
    -device e1000-82545em,netdev=hub0port0,id=mac_vnet0 \
    -monitor stdio

