# Docker Audio Copy 1.8.0
This project is a Docker container for [Exact Audio Copy](https://www.exactaudiocopy.de/) (EAC) version `1.8`. It allows Linux (and Mac) users to easily and reliably run EAC in a preconfigured environment. Graphical windows & audio can be forwarded to the host machine through X11 and PulseAudio. The CD-ROM drive is already added in the Wine config and fstab. Just **Pull & Run**; no additional host configuration is needed to use the software.


## License
**I DO NOT OWN THE COPYRIGHT TO THE WRAPPED SOFTWARE**, nor does this wrapper violate the license of the wrapped software. The Docker image does not contain any binary of the (proprietary) software that it wraps. It is the end user who downloads the installer and accepts the **END USER AGREEMENT** on the initial run of the container.


## Pull & Run
```sh
docker pull docker-audio-copy
mkdir .wine
docker run -it --rm \
  --device /dev/sr0 \
  -v .wine:/mnt/wine \
  -v /run/user/$(id -u)/pulse:/run/user/1000/pulse \
  -v "${XAUTHORITY:-${HOME}/.Xauthority}:/home/ubuntu/.Xauthority:ro" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -e DISPLAY \
  docker-audio-copy
```
Use the default install location!

### Notes;
1. The `.wine` prefix folder (on the host) must be created beforehand by the user. If not, Docker may create it with root permissions, which the container will NOT accept.  
2. The `pulse` volume mount is optional, and is used to forward audio to the host machine (through PulseAudio).


## Technical details
### Initial run
The first time the container runs, it will go through the following steps;
1. Copies a pre-configured wine prefix into the empty volume mount (folder).
2. Downloads and runs the (interactive) installer using the mounted Wine prefix.

On following runs, the container only executes;

3. Starts the application executable using the mounted Wine prefix.

### Persistence
The software install, calibration results and other settings like AccurateRip are saved in the mounted Wine volume. A new container will re-use the existing (Wine) environment, making the settings persistent.

However, after configuring AEC, it is **highly recommended** to save the settings as a profile. Make sure to save it in the `C:/` drive, and **NOT** in the ephemeral Linux filesystem (`Z:`)! You may then want to backup the Wine prefix folder.

### CD-ROM
A CD-ROM drive can be forwarded through the `--device /dev/sr0` argument. It has already been mapped to the `D:` drive in the Wine config. **NO NEED** to configure the `fstab` or add yourself to the `cdrom` group (on the host).

### Graphics
Using the `.X11-unix` and `.Xauthority` mounts, the application's windows are forwarded to the host's X11 display (server). Most Linux distro's should come with an X11 server OR x11 bridge for Wayland. Mac users may have to install a bridge themselves before being able to use this container. The result is unnoticeable compared to the non-container equivalent.

### Sound
The `pulse` mount is enough to allow sound to be passed to PulseAudio on the host machine. Credits to [docker-pulseaudio-example](https://github.com/TheBiggerGuy/docker-pulseaudio-example), it is surprisingly simple. PipeWire can bridge with Pulse, and is therefore also supported. Alsa is not supported, but [could easily be added](https://github.com/mviereck/x11docker/wiki/Container-sound:-ALSA-or-Pulseaudio).


## Versions
Older versions probably work too, but this setup is confirmed to work with the following software versions on the host;

| Software | Version        |
|----------|----------------|
| Docker   | 27.3.1         |
| Pulse    | 16.1.0         |
| X.org    | 24.1.2 (X11.0) |
