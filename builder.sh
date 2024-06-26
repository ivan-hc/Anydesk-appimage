#!/bin/sh

APP=anydesk

mkdir -p tmp
cd tmp

# DOWNLOADING THE DEPENDENCIES
if test -f ./appimagetool; then
	echo " appimagetool already exists" 1> /dev/null
else
	echo " Downloading appimagetool..."
	wget -q "$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | sed 's/"/ /g; s/ /\n/g' | grep -o 'https.*continuous.*tool.*86_64.*mage$')" -O appimagetool
fi
if test -f ./pkg2appimage; then
	echo " pkg2appimage already exists" 1> /dev/null
else
	echo " Downloading pkg2appimage..."
	wget -q https://raw.githubusercontent.com/ivan-hc/AM-application-manager/main/tools/pkg2appimage
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

ingredients:
  dist: oldstable
  sources:
    - deb http://ftp.us.debian.org/debian/ oldstable main contrib non-free
  packages:
    - $APP
    - libglx-mesa0
    - xdg-utils" >> recipe.yml


for arg in $ARGS; do echo "    - $arg" >> ./recipe.yml; done

# ...RUN PKG2APPIMAGE...
./pkg2appimage ./recipe.yml

# ...REPLACING THE EXISTING APPRUN WITH A CUSTOM ONE (DON'T FORGET TO EDIT IT THE WAY YOU PREFER)...
rm -R -f ./$APP/$APP.AppDir/AppRun
cat > AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
export PATH="${HERE}"/usr/bin/:"${HERE}"/usr/sbin/:"${HERE}"/usr/games/:"${HERE}"/bin/:"${HERE}"/sbin/:"${PATH}"
export LD_LIBRARY_PATH=/lib/:/usr/lib/x86_64-linux-gnu/:/usr/lib/:/lib64/:"${HERE}"/usr/lib/:"${HERE}"/usr/lib/:"${HERE}"/usr/lib64/:"${HERE}"/usr/lib32/:"${HERE}"/usr/lib/:"${HERE}"/usr/lib/x86_64-linux-gnu/:"${HERE}"/usr/lib32/:"${HERE}"/usr/lib64/:"${HERE}"/lib/:"${HERE}"/lib/:"${HERE}"/lib/x86_64-linux-gnu/:"${HERE}"/lib32/:"${HERE}"/lib64/:"${LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="${HERE}"/usr/share/:"${XDG_DATA_DIRS}"
export PERLLIB="${HERE}"/usr/share/perl5/:"${HERE}"/usr/lib/perl5/:"${PERLLIB}"
export GSETTINGS_SCHEMA_DIR="${HERE}"/usr/share/glib-2.0/schemas/:"${GSETTINGS_SCHEMA_DIR}"
EXEC=$(grep -e '^Exec=.*' "${HERE}"/*.desktop | head -n 1 | cut -d "=" -f 2- | sed -e 's|%.||g')
exec ${HERE}/usr/bin/anydesk "$@" 2> /dev/null
EOF
chmod a+x AppRun
cp ./AppRun /opt/$APP/
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
ARCH=x86_64 VERSION=$(./appimagetool -v | grep -o '[[:digit:]]*') ./appimagetool -s ./$APP/$APP.AppDir;
underscore=_
mkdir version
mv ./$APP/$APP$underscore*.deb ./version/
version=$(ls ./version)

# ...EXPORT THE APPDIR TO AN APPIMAGE!
ARCH=x86_64 VERSION=$(./appimagetool -v | grep -o '[[:digit:]]*') ./appimagetool -s ./$APP/$APP.AppDir;
mkdir version
mv ./$APP/$APP$underscore*.deb ./version/
version=$(ls ./version | cut -c 9- | rev | cut -c 11- | rev)

cd ..
mv ./tmp/*.AppImage ./Anydesk-$version-x86_64.AppImage
