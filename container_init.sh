#!/bin/sh

# Stop CUPSD if it is running
echo "Stopping cupsd on Synology..."
sudo synosystemctl stop cupsd
sudo synosystemctl stop cups-lpd
sudo synosystemctl stop cups-service-handler
sudo synosystemctl disable cupsd
sudo synosystemctl disable cups-lpd
sudo synosystemctl disable cups-service-handler

# Get Printer location
KEY="Hewlett"
echo -e "Getting printer info for key '$KEY'..."
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


echo -e "Wait a bit until docker is up and running"
sleep 10s

# Stop Container
echo -e "Stopping current container..."
echo $(docker kill cups-server)
echo $(docker rm cups-server)

# Run Docker
echo -e "\nRunning container..."
containerID=$(docker run \
    --name cups-server \
    --restart unless-stopped \
    --privileged \
    --net host \
    -e CUPSADMIN=cups \
    -e CUPSPASSWORD=cups \
    -v /var/run/dbus:/var/run/dbus \
    -v /dev/bus/usb:/dev/bus/usb \
    -v /volume1/docker/cups/services:/services \
    -v /volume1/docker/cups/configs:/config \
    -v /volume1/docker/cups/logs:/var/log/cups \
    drova326/synology-cups:latest)
echo $containerID


echo "Done!"

exit 0
