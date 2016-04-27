FROM snarlysodboxer/ruby-ree-1.8.7-2012.02:latest
MAINTAINER david amick <docker@davidamick.com>

ENV DEBIAN_FRONTEND noninteractive

RUN /bin/bash -c "apt-get update -qq && apt-get -y build-dep pure-ftpd && apt-get install -y openbsd-inetd && apt-get -y autoclean && apt-get -y autoremove"
RUN /bin/bash -c "mkdir /tmp/pure-ftpd/ && \
  cd /tmp/pure-ftpd/ && \
  wget --no-check-certificate https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.42.tar.gz && \
  tar zxvf pure-ftpd-1.0.42.tar.gz && \
  cd pure-ftpd-1.0.42 && \
  ./configure --prefix /usr --exec-prefix /usr/sbin --sysconfdir=/etc/pure-ftpd \
    CFLAGS=-DMAX_USER_LENGTH=128U \
    --with-everything --with-privsep --with-tls --with-rfc2640 --without-capabilities && \
  make && make install && \
  mv src/pure-ftpd /usr/sbin/ && mv src/pure-authd /usr/sbin/ && \
  rm /tmp/pure-ftpd -rf"

ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
