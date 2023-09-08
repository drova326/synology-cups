## CUPS for DSM7 with firmware downloader mod (for printers like HP)

Fork based on [znetwork/synology-airprint](https://github.com/ziwork/synology-airprint), which based on [quadportnick/docker-cups-airprint](https://github.com/quadportnick/docker-cups-airprint) and [chuckcharlie/docker-cups-airprint](https://github.com/chuckcharlie/docker-cups-airprint)

This Ubuntu-based Docker image runs a CUPS instance that is meant as an AirPrint relay for printers that not Synology capable.
* `Included drivers HP, Samsung, Canon, Xerox, etc.`

## Make DSM7 download firmware to printer.

* Copy `<your_firmware>.dl` to `/lib/udev/script/<your_firmware>.dl` (from http://oleg.wl500g.info/hplj/ for example)
* Run `print_info.sh` to get `vendorID` and `modelID` of your printer
* Change `/lib/udev/script/printer-usbdev-check.py` script on your DSM7 after 239 row like this:
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
Now you can unplug/plug printer. If all right you should hear your printer wake up and make some noise.

Or you can run `sudo tail -f /var/log/messages` and see `Firmware sent to printer` in output when plugin printer. 

Check permissions (ls -l /dev/usb/lp0). Must be `crw-rw---- 1 root lp 180, 0 Sep  8 10:01 /dev/usb/lp0`

## Run docker with CUPS
* Enter to rep dir: `cd <rep_dir>`
* Create dirs for volums:
    ```
    -v /volume1/docker/cups/services:/services
    -v /volume1/docker/cups/configs:/config
    -v /volume1/docker/cups/logs:/var/log/cups
    ```
* run: `sudo sh container_init.sh`
* Go to http://[host ip]:631 using the 'cups/cups'
* Add your printer (make sure you select 'Share This Printer'). If you use HP printers recomended use "Foomatic/foo2xqx" drivers
  ***After configuring your printer, you need to close the web browser for at least 60 seconds. CUPS will not write the config files until it detects the connection is closed for as long as a minute.***
* Enjoy
