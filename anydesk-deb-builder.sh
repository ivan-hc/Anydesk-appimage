#!/bin/sh

APP=anydesk

mkdir -p tmp
cd tmp

# DOWNLOADING THE DEPENDENCIES
if test -f ./appimagetool; then
	echo " appimagetool already exists" 1> /dev/null
else
	echo " Downloading appimagetool..."
	wget -q https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
fi
if test -f ./pkg2appimage; then
	echo " pkg2appimage already exists" 1> /dev/null
else
	echo " Downloading pkg2appimage..."
	wget -q "$(curl -Ls https://api.github.com/repos/AppImageCommunity/pkg2appimage/releases/latest | sed 's/[()",{} ]/\n/g' | grep -io "http.*x86_64.*appimage$" | head -1)" -O pkg2appimage
fi
chmod a+x ./appimagetool ./pkg2appimage

# CREATING THE APPIMAGE: DOWNLOAD THE DEB PACKAGE AND GET THE FULL LIST OF DEPENDENCES...

DEB=$(wget -q "http://deb.anydesk.com/pool/main/a/anydesk/" -O -| grep -E "anydesk.*amd64.deb" | cut -d'"' -f2 | grep -w -v "/deb" | grep -w -v sum | tail -1)
wget http://deb.anydesk.com/pool/main/a/anydesk/$DEB
ar x ./*.deb
tar fx ./control.tar.gz
echo "" >> deps
cat control | grep -e "Depends:" | tr ' ' '\n' | grep -w -v '(' | grep -w -v ',' | grep -w -v '|' | grep -w -v ')' | tr ',' '\n' | grep -w -v "" >> deps
ARGS=$(sed '1d' ./deps)

# ...CREATE THE DIRECTORY OF THE APP AND MOVE THE DEB PACKAGE DOWNLOADED PREVIOUSLY INTO IT...
mkdir -p $APP
mv ./$DEB ./$APP/

# ...COMPILE THE RECIPE...
rm -f ./recipe.yml
echo "app: $APP
binpatch: true

ingredients:
  dist: oldstable
  script:
    - wget -q http://ftp.debian.org/debian/pool/main/g/gtk+2.0/$(curl -Ls https://packages.debian.org/oldstable/amd64/libgtk2.0-0/download | tr '">< ' '\n' | grep -i "libgtk2.*amd64.deb$" | head -1)
  sources:
    - deb http://ftp.debian.org/debian/ oldstable main contrib non-free
    - deb http://security.debian.org/debian-security/ oldstable-security main contrib non-free
    - deb http://ftp.debian.org/debian/ oldstable-updates main contrib non-free
  packages:
    - $APP
    - libglx-mesa0
    - xdg-utils
    - libgtk2.0-0" >> recipe.yml

for arg in $ARGS; do echo "    - $arg" >> ./recipe.yml; done

# ...RUN PKG2APPIMAGE...
./pkg2appimage ./recipe.yml

# ...REPLACING THE EXISTING APPRUN WITH A CUSTOM ONE (DON'T FORGET TO EDIT IT THE WAY YOU PREFER)...
rm -R -f ./$APP/$APP.AppDir/AppRun
cat > AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
exec ${HERE}/usr/bin/anydesk "$@"
EOF
chmod a+x AppRun
mv ./AppRun ./$APP/$APP.AppDir

# IMPORT THE LAUNCHER AND THE ICON TO THE APPDIR IF THEY NOT EXIST
if test -f ./$APP/$APP.AppDir/*.desktop; then
	echo "The desktop file exists"
else
	echo "Trying to get the .desktop file"
	cp ./$APP/$APP.AppDir/usr/share/applications/*$(ls . | grep -i $APP | cut -c -4)*desktop ./$APP/$APP.AppDir/ 2>/dev/null
fi

ICONNAME=$(cat ./$APP/$APP.AppDir/*desktop | grep "Icon=" | head -1 | cut -c 6-)
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/22x22/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/24x24/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/32x32/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/48x48/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/64x64/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/128x128/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/256x256/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/512x512/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/scalable/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/applications/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null

sed -i 's#Exec=/usr/bin/anydesk#Exec=anydesk#g' ./$APP/$APP.AppDir/*.desktop

# ...EXPORT THE APPDIR TO AN APPIMAGE!
underscore=_
mkdir version
mv ./$APP/$APP$underscore*.deb ./version/
VERSION=$(ls ./version | cut -c 9- | rev | cut -c 11- | rev)

APPNAME="Anydesk"
REPO="Anydesk-appimage"
TAG="continuous"
UPINFO="gh-releases-zsync|$GITHUB_REPOSITORY_OWNER|$REPO|$TAG|*x86_64.AppImage.zsync"

ARCH=x86_64 ./appimagetool --comp zstd --mksquashfs-opt -Xcompression-level --mksquashfs-opt 20 \
	-u "$UPINFO" \
	./"$APP"/"$APP".AppDir "$APPNAME"_"$VERSION"-x86_64.AppImage

cd ..
mv ./tmp/*.AppImage* ./
