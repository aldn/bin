#!/bin/sh
sudo rmmod nvidia_uvm
sudo rmmod nvidia_modeset
sudo rmmod nvidia
sudo tee /proc/acpi/bbswitch <<<OFF
