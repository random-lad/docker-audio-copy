#!/bin/bash

if [ -z "$VNC" ] && [ ! -f ~/.Xauthority ]; then
  echo "$HOME/.Xauthority is not available, please mount it. Exiting ..."
  exit 1
fi

if [ ! -d /tmp/.X11-unix ]; then
  echo "/tmp/.X11-unix is not available, please mount it. Exiting ..."
  exit 1
fi

if [ ! -d /mnt/wine ]; then
  echo "Wine prefix is not available at /mnt/wine, exiting ..."
  exit 1
fi

if [ ! "$(ls -A /mnt/wine)" ]; then
  echo "Mount point is empty, poputating it with wine prefix ..."
  mv ~/.wine/* /mnt/wine
else
  echo "Mount point is populated, continuing ..."
fi

if [ ! -f /mnt/wine/drive_c/Program\ Files/Exact\ Audio\ Copy/EAC.exe ]; then
  echo "EAC is not installed, downloading and installing it ..."
  wget -nc https://www.exactaudiocopy.de/eac-$EAC_VERSION.exe

  echo "Installing EAC ..."
  wine ~/eac-$EAC_VERSION.exe
  wineserver -k

  echo "EAC is installed, cleaning up ..."
  rm -f ~/eac-$EAC_VERSION.exe
fi

echo "Starting EAC ..."
wine /mnt/wine/drive_c/Program\ Files/Exact\ Audio\ Copy/EAC.exe
