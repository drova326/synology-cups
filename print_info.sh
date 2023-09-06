#!/bin/sh

KEY="Hewlett"
echo "Getting printer info for key '$KEY'..."
echo ""
LOC=$(lsusb|grep $KEY|awk '{print $1}')
ID=$(lsusb|grep $KEY|awk '{print $2}')
if [ -z "${LOC}" ]; then
    echo "Device for key '$KEY' is not found. Printer is connected?"
else
    VENDOR="/dev/bus/usb/00${DEV:3:1}"
    PRODUCT="/dev/bus/usb/00${DEV:3:1}"
    echo "USB: /dev/bus/usb/00${LOC:3:1}"
    echo "VENDOR: ${ID:0:4}"
    echo "PRODUCT: ${ID:05:4}"	
fi

