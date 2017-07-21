#!/bin/bash
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

DEV_PATH="$ROOT/dev_scripts/onionshare-gui"
APP_PATH="$ROOT/dist/OnionShare.app"
APP_BIN_PATH="$APP_PATH/Content/MacOS/OnionShare"
PKG_PATH="$ROOT/dist/OnionShare.pkg"
IDENTITY_NAME_APPLICATION="Developer ID Application: MSJ 2018"
IDENTITY_NAME_INSTALLER="Developer ID Installer: MSJ 2018"
IDENTITY_PACKAGE="MSJ 2018"

PYTHON_VERSION="3.5"
PYINSTALLER="/Library/Frameworks/Python.framework/Versions/$PYTHON_VERSION/bin/pyinstaller"
PYTHON="/Library/Frameworks/Python.framework/Versions/$PYTHON_VERSION/bin/python$PYTHON_VERSION"

cd $ROOT

# deleting dist
echo Deleting dist folder
rm -rf $ROOT/dist &>/dev/null 2>&1

# build the .app
echo Building OnionShare.app
$PYINSTALLER $ROOT/install/pyinstaller.spec
$PYTHON $ROOT/install/get-tor-osx.py

# create a symlink of onionshare-gui called onionshare, for the CLI version
cd $ROOT/dist/OnionShare.app/Contents/MacOS
ln -s "/Users/pierrecharlier/github/onionshare/dev_scripts/onionshare-gui" ./onionshare
#cp "$DEV_PATH" ./onionshare-gui

cd $ROOT



if [ "$1" = "--release" ]; then
  mkdir -p dist
  #mkdir "$APP_PATH/Ressources"
  
  echo "Codesigning the app bundle"
  codesign --verbose --deep -s "$IDENTITY_NAME_APPLICATION" "$APP_PATH"
#  codesign --verbose --deep --keychain "Extras" --force -s "$IDENTITY_NAME_APPLICATION" -v "$APP_BIN_PATH"
#  codesign --deep --keychain "Extras" --force -s "$IDENTITY_NAME_APPLICATION" "$APP_PATH"
  
  echo "Creating an installer"
  productbuild -v --sign "$IDENTITY_NAME_INSTALLER" --component "$APP_PATH" /Applications "$PKG_PATH"
#  productbuild --keychain "Extras" --sign $IDENTITY_NAME_INSTALLER --component "$APP_PATH" /Applications "$PKG_PATH"
#productbuild --identifier local.msj2018.OnionShare.pkg.app --sign "$IDENTITY_PACKAGE" --component "$APP_PATH" /Applications "$PKG_PATH"
  echo "Cleaning up"
  rm -rf "$APP_PATH"

  echo "All done, your installer is in: $PKG_PATH"
fi
