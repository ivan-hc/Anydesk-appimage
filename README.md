This repository creates and distributes the unofficial Appimage of Anydesk.

From here you can download the scripts to build it from the official deb package (for a lighweight version) on top of [JuNest](https://github.com/fsquillace/junest), the lightweight Arch Linux based distro that runs, without root privileges, on top of any other Linux distro.

-------------------------
### Downloads
Continuous builds based on JuNest* are released each Sunday, you can download them from:

***https://github.com/ivan-hc/GIMP-appimage/releases/tag/continuous*** 

JuNest-based AppImages have more compatibility with much older systems. 

Compiling these so-called "ArchImages" is easier and the Arch Linux base is a guarantee of continuity being one of the most important GNU/Linux distributions, supported by a large community that offers more guarantees of continuity, while usually unofficial PPAs are mantained by one or two people and built as a third-party repository for Ubuntu, a distro that is more inclined to push Snaps as official packaging format instead of DEBs.

---------------------------------

## Install and update it with ease

I wrote two bash scripts to install and manage the applications: [AM](https://github.com/ivan-hc/AM-Application-Manager) and [AppMan](https://github.com/ivan-hc/AppMan). Their dual existence is based on the needs of the end user.

| [**"AM" Application Manager**](https://github.com/ivan-hc/AM-Application-Manager) |
| -- |
| <sub>***If you want to install system-wide applications on your GNU/Linux distribution in a way that is compatible with [Linux Standard Base](https://refspecs.linuxfoundation.org/lsb.shtml) (all third-party apps must be installed in dedicated directories under `/opt` and their launchers and binaries in `/usr/local/*` ...), just use ["AM" Application Manager](https://github.com/ivan-hc/AM-Application-Manager). This app manager requires root privileges only to install / remove applications, the main advantage of this type of installation is that the same applications will be available to all users of the system.***</sub>
[![Readme](https://img.shields.io/github/stars/ivan-hc/AM-Application-Manager?label=%E2%AD%90&style=for-the-badge)](https://github.com/ivan-hc/AM-Application-Manager/stargazers) [![Readme](https://img.shields.io/github/license/ivan-hc/AM-Application-Manager?label=&style=for-the-badge)](https://github.com/ivan-hc/AM-Application-Manager/blob/main/LICENSE)

| [**"AppMan"**](https://github.com/ivan-hc/AppMan)
| --
| <sub>***If you don't want to put your app manager in a specific path but want to use it portable and want to install / update / manage all your apps locally, download ["AppMan"](https://github.com/ivan-hc/AppMan) instead. With this script you will be able to decide where to install your applications (at the expense of a greater consumption of resources if the system is used by more users). AppMan is portable, all you have to do is write the name of a folder in your `$HOME` where you can install all the applications available in [the "AM" database](https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs), and without root privileges.***</sub>
[![Readme](https://img.shields.io/github/stars/ivan-hc/AppMan?label=%E2%AD%90&style=for-the-badge)](https://github.com/ivan-hc/AppMan/stargazers) [![Readme](https://img.shields.io/github/license/ivan-hc/AppMan?label=&style=for-the-badge)](https://github.com/ivan-hc/AppMan/blob/main/LICENSE)

-------------------------
### Reduce the size of the JuNest based Appimage
You can analyze the presence of excess files inside the AppImage by extracting it:

    ./*.AppImage --appimage-extract
To start your tests, run the "AppRun" script inside the "squashfs-root" folder extracted from the AppImage:

    ./squashfs-root/AppRun

-------------------------
### *Special Credits*
- JuNest https://github.com/fsquillace/junest
- Arch Linux https://archlinux.org
