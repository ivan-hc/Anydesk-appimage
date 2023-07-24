This repository creates and distributes the unofficial Appimage of Anydesk.

From here you can download the scripts to build it from the official deb package (for a lighweight version) on top of [JuNest](https://github.com/fsquillace/junest), the lightweight Arch Linux based distro that runs, without root privileges, on top of any other Linux distro.

-------------------------
### Downloads
Continuous builds based on JuNest* are released each Sunday, you can download them from:

***https://github.com/ivan-hc/GIMP-appimage/releases/tag/continuous*** 

JuNest-based AppImages have more compatibility with much older systems. 

Compiling these so-called "ArchImages" is easier and the Arch Linux base is a guarantee of continuity being one of the most important GNU/Linux distributions, supported by a large community that offers more guarantees of continuity, while usually unofficial PPAs are mantained by one or two people and built as a third-party repository for Ubuntu, a distro that is more inclined to push Snaps as official packaging format instead of DEBs.

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
