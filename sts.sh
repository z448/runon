#!/bin/bash

if [ $0 == 'str' ]; then
   $HOME/nps/bin/control $($HOME/nps/bin/control | tail -1 | cut -d' ' -f4,4) start $1
elif [ $0 == 'stp' ]; then
   $HOME/nps/bin/control $($HOME/nps/bin/control | tail -1 | cut -d' ' -f4,4) stop $1
elif [ $0 == 'strm' ]; then
   $HOME/nps/bin/control $($HOME/nps/bin/control | tail -1 | cut -d' ' -f4,4) start_missing
else
   $HOME/nps/bin/control $($HOME/nps/bin/control | tail -1 | cut -d' ' -f4,4) status
fi

#add into main script or distribute to remote hosts and create symlinks to this file (str, stp, strm) for different results