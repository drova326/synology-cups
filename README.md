## CUPS for DSM7 with firmware downloader mod (for printers like HP)

Fork based on [znetwork/synology-airprint](https://github.com/ziwork/synology-airprint), => [quadportnick/docker-cups-airprint](https://github.com/quadportnick/docker-cups-airprint) and [chuckcharlie/docker-cups-airprint](https://github.com/chuckcharlie/docker-cups-airprint)

This Ubuntu-based Docker image runs a CUPS instance that is meant as an AirPrint relay for printers that are already on the network but not AirPrint capable.
* `Included drivers HP, Samsung, Canon, Xerox, etc.`

## Make DSM7 download firmware to printer.

* Copy <your_firmware>.dl to /lib/udev/script/<your_firmware>.dl (from http://oleg.wl500g.info/hplj/ for example)
* Run `print_info.sh` to get vendor and model of your printer
* Change `/lib/udev/script/printer-usbdev-check.py` script on your DSM7 after 239 row
```
    # close usbdev.conf and release lock
    fd.close()

    vendorID = printerid.split(':')[0]
    modelID = printerid.split(':')[1]
    if (vendorID == '*<your_vendor>' and modelID == '<your_model>'):
        time.sleep(2)
        subprocess.call('cat /lib/udev/script/<your_firmware>.dl > /dev/usb/%s' % devname, shell=True)
        log_msg('Firmware sent to printer ' % printerid)
        time.sleep(15)
        
    return 0
```
Now you can unplug/plug printer. If all right you should hear your printer wake up and make some noise.

## Run docker with CUPS
* Enter to rep dir: `cd <rep_dir>`
* run: `sudo sh container_init.sh`
* Go to http://[host ip]:631 using the 'cups/cups'
* Add your printer (make sure you select 'Share This Printer')
* ***After configuring your printer, you need to close the web browser for at least 60 seconds. CUPS will not write the config files until it detects the connection is closed for as long as a minute.***
* Enjoy
