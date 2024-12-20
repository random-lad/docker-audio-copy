FROM ubuntu:24.04

# Install preliminary dependencies
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get install -y \
    gnupg2 \
    software-properties-common \
    wget

# Add the WineHQ repository
RUN dpkg --add-architecture i386 \
 && wget -nc https://dl.winehq.org/wine-builds/winehq.key \
 && apt-key add winehq.key \
 && apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ noble main'

# Install wine and tools
ARG WINE_VERSION=10.0~rc2~noble-1
RUN apt-get update && apt-get install -y \
    winehq-devel=$WINE_VERSION \
    winetricks \
    libvulkan1 \
    libvulkan1:i386 \
    pulseaudio-utils \
    xvfb \
    kdialog \
    xmacro \
 && rm -rf /var/lib/apt/lists/*

# Set up unprivileged user
ENV UNAME=ubuntu
ENV HOME=/home/$UNAME
WORKDIR /$HOME

RUN export UNAME=$UNAME UID=1000 GID=1000 \
 && mkdir -p "/home/${UNAME}" \
 && echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd \
 && echo "${UNAME}:x:${UID}:" >> /etc/group \
 && mkdir -p /etc/sudoers.d \
 && echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} \
 && chmod 0440 /etc/sudoers.d/${UNAME} \
 && chown ${UID}:${GID} -R /home/${UNAME} \
 && gpasswd -a ${UNAME} audio

# Set up CD-ROM support for Wine
RUN  echo '/dev/sr0 /mnt/drive0 auto ro,user,noauto,unhide 0 0' | tee -a /etc/fstab >/dev/null
RUN  mkdir -p /mnt/drive0
RUN  gpasswd -a $UNAME cdrom

# Switch to user
USER $UNAME

# Set up the Wine environment
ENV WINEARCH=win32
ENV WINEPREFIX=$HOME/.wine

# Install Windows dependencies using winetricks
ENV WINEDLLOVERRIDES="mscoree,mshtml="
RUN xvfb-run -e /dev/stdout winetricks -q dotnet20 || true

# Configure CD-ROM using xmacro and winecfg
ENV DISPLAY=:0
COPY ./src/drive.xmacro /tmp/drive.xmacro
RUN Xvfb $DISPLAY -screen 0 1024x768x16 \
  & winecfg \
  & sleep 6 \
 && xmacroplay $DISPLAY < /tmp/drive.xmacro \
 && sleep 6

# Set up audio support
COPY src/pulse-client.conf /etc/pulse/client.conf
# Copy the source code
COPY src/init.sh init.sh

# Set up runtime environment
ENV WINEPREFIX=/mnt/wine/
ENV EAC_VERSION=1.8

# Set up script for installing the application
CMD ["./init.sh"]
