## CUPS for DSM7 with firmware downloader mod (for printers like HP)

Fork from [znetwork/synology-airprint](https://github.com/ziwork/synology-airprint), which based on [quadportnick/docker-cups-airprint](https://github.com/quadportnick/docker-cups-airprint) and [chuckcharlie/docker-cups-airprint](https://github.com/chuckcharlie/docker-cups-airprint)

This Ubuntu-based Docker image runs a CUPS instance that is meant as an AirPrint relay for printers that not Synology capable.
* `Included drivers HP, Samsung, Canon, Xerox, etc.`

## Preparatory work

* Copy `<your_firmware>.dl` to `/lib/udev/script/<your_firmware>.dl` (from http://oleg.wl500g.info/hplj/ for example)
* Run `print_info.sh` or simple use `lsusb` to get `vendorID` and `modelID` of your printer 

## Make DSM7 download firmware to printer.

* Edit `/lib/udev/script/printer-usbdev-check.py` script on your DSM7 after 239 row like this:
```
    # close usbdev.conf and release lock
    fd.close()

    vendorID = printerid.split(':')[0]
    modelID = printerid.split(':')[1]
    if (vendorID == '<vendorID>' and modelID == '<modelID>'):
        time.sleep(2)
        subprocess.call('cat /lib/udev/script/<your_firmware>.dl > /dev/usb/%s' % devname, shell=True)
        log_msg('Firmware sent to printer ' % printerid)
        time.sleep(15)
        
    return 0
```

## Another way to autoload firmware:

* Create simple script `/lib/udev/script/firmware_loader.sh`:
    ```
    #!/bin/sh
    cat /lib/udev/script/<your_firmware>.dl > /dev/usb/lp0
    ```
* Create rule `/usr/lib/udev/rules.d/99-hp-custom.rules`:
    ```
    SUBSYSTEM=="usb", ATTRS{idVendor}=="<vendorID>", ATTRS{idProduct}=="<modelID>", GROUP="lp", MODE="777", ACTION=="add", RUN+="/lib/udev/script/firmware_loader.sh"
    ```
* Set permittions:
    ```
    sudo chmod 644 /usr/lib/udev/rules.d/99-hp-custom.rules
    sudo chmod +x /lib/udev/script/firmware_loader.sh
    ```
* Reboot DSM or restart udev:
    ```
    sudo udevadm control --reload-rules && udevadm trigger
    ```

**!!! Don't forget to change `<vendorID>`, `<modelID>` and `<your_firmware>.dl` for your own.**

Now you can unplug/plug (or off/on) printer. If all right you should hear your printer wake up and make some noise (twice).

If you have problems check permissions (ls -l /dev/usb/lp0). Must be `crw-rw---- 1 root lp 180, 0 Sep  8 10:01 /dev/usb/lp0`. Also you can check logs `sudo tail -f /var/log/messages`

After we have connected our DSM7 and printer, let's make the printer network

## Run docker with CUPS
* Create dirs for volums:
    ```
    -v /volume1/docker/cups/services:/services
    -v /volume1/docker/cups/configs:/config
    -v /volume1/docker/cups/logs:/var/log/cups
    ```
* run: `sudo sh container_init.sh`
* Go to `http://[host ip]:631` using the 'cups/cups'
* Add your printer (make sure you select 'Share This Printer'). If you use HP printers you must to use `"Foomatic/foo2xqx"` drivers in cups interface.  
  ***After configuring your printer, you need to close the web browser for at least 60 seconds. CUPS will not write the config files until it detects the connection is closed for as long as a minute.***
* Enjoy
