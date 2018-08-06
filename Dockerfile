FROM binhex/arch-rtorrentvpn
MAINTAINER xvicarious

ADD build/root/*.sh /root/

RUN chmod +x /root/pyrocore.install.sh && \
    /bin/bash /root/pyrocore.install.sh
