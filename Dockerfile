FROM ubuntu:jammy
LABEL description="AIRPRINT FROM SYNOLOGY DSM 7 (HP, SAMSUNG, ETC)"

RUN apt-get update && apt-get install -y \
	locales \
	hplip \
	printer-driver-foo2zjs-common \
	printer-driver-foo2zjs \
	printer-driver-splix \
	printer-driver-gutenprint \
	brother-lpr-drivers-extra \
	brother-cups-wrapper-extra \
	gutenprint-doc \
	gutenprint-locales \
	libgutenprint9 \
	libgutenprint-doc \
	ghostscript \
	cups \
	cups-pdf \
	cups-client \
	cups-filters \
	inotify-tools \
	avahi-daemon \
	avahi-discover \
	python3 \
	python3-dev \
	python3-pip \
	python3-cups \
	wget \
	rsync \
	&& rm -rf /var/lib/apt/lists/*

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services
VOLUME /var/log/cups

# Add scripts
ADD root /
RUN chmod +x /root/*

#Run Script
CMD ["/root/run_cups.sh"]

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen *:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing No/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf && \
	echo "BrowseWebIF Yes" >> /etc/cups/cupsd.conf && \
	echo "LogLevel debug" >> /etc/cups/cupsd.conf
