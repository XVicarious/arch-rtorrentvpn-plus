#!/bin/bash

set -e

packages="python2 python2-virtualenv python2-pip python2-setuptools base-devel"

if [[ ! -z "${packages}" ]]; then
    pacman -S --needed $packages --noconfirm
fi

mkdir -p ~/bin ~/.local
git clone "https://github.com/pyroscope/pyrocore.git" ~/.local/pyroscope
~/.local/pyroscope/update-to-head.sh
exec $SHELL -l
pyroadmin --create-config --config-dir /config/pyroscope

# Make a full, current backup of the session data
rtxmlrpc -q session.save
tar cvfz ~/session-backup-$(date +'%Y-%m-%d').tgz \
        $(echo $(rtxmlrpc session.path)/ | tr -s / /)*.torrent*

# Set missing "loaded" times to that of the .torrent file or data path
rtcontrol loaded=0 metafile='!' -q -sname -o '{{py:from pyrobase.osutil import shell_escape as quote}}
    echo {{d.name | quote}}
        test ! -f {{d.metafile | quote}} || rtxmlrpc -q d.custom.set {{d.hash}} tm_loaded \$(stat -c "%Y" {{d.metafile | quote}})
            rtxmlrpc -q d.save_full_session {{d.hash}}' | bash +e
rtcontrol loaded=0 is_ghost=no path='!' -q -sname -o '{{py:from pyrobase.osutil import shell_escape as quote}}
                echo {{d.name | quote}}
                    test ! -e {{d.realpath | quote}} || rtxmlrpc -q d.custom.set {{d.hash}} tm_loaded \$(stat -c "%Y" {{d.realpath | quote}})
                        rtxmlrpc -q d.save_full_session {{d.hash}}' | bash +e

                        # Set missing "completed" times to that of the data file or directory
rtcontrol completed=0 done=100 path='!' is_ghost=no -q -sname -o '{{py:from pyrobase.osutil import shell_escape as quote}}
                            echo {{d.name | quote}}
                                test ! -e {{d.realpath | quote}} || rtxmlrpc -q d.custom.set {{d.hash}} tm_completed \$(stat -c "%Y" {{d.realpath | quote}})
                                    rtxmlrpc -q d.save_full_session {{d.hash}}' | bash +e
