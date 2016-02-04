FROM ubuntu:14.04
MAINTAINER david amick <docker@davidamick.com>

ENV DEBIAN_FRONTEND noninteractive

RUN /bin/bash -c "apt-get update -qq && apt-get install -qy pure-ftpd && apt-get -y autoclean && apt-get -y autoremove"

ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
