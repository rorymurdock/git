#!/bin/zsh
# This could be changed in the make file but
# that was proving difficult for such a small change
set -ex

# Get the xcode version
/usr/bin/xcodebuild -version

XCODE_PATH="/Applications/Xcode.app"

# Get the git version and make the new package name
pkg_filename=$(find git*.pkg | head -n 1)
pattern='git-(.*)-intel'
[[ "$pkg_filename" =~ $pattern ]]

git_version=${match[1]}
new_pkg_filename="git-$git_version.pkg"
new_dmg_filename="git-$git_version.dmg"

if [ -z "$git_version" ]
then
   echo "Unable to find git version"
   echo "Pkg name: $pkg_filename"
   exit 1
fi

echo "Found Git version $git_version"

# Extract pkg
pkgutil --expand-full "$pkg_filename" "pkg_extract"

# Code sign all the bins
/usr/bin/codesign -s "$APPLICATION_CERTIFICATE_NAME" --timestamp -o runtime "pkg_extract/Payload/git/bin/git-credential-osxkeychain"
/usr/bin/codesign -s "$APPLICATION_CERTIFICATE_NAME" --timestamp -o runtime "pkg_extract/Payload/git/bin/git-shell"
/usr/bin/codesign -s "$APPLICATION_CERTIFICATE_NAME" --timestamp -o runtime "pkg_extract/Payload/git/bin/git"
/usr/bin/codesign -s "$APPLICATION_CERTIFICATE_NAME" --timestamp -o runtime "pkg_extract/Payload/git/libexec/git-core/git-http-push"
/usr/bin/codesign -s "$APPLICATION_CERTIFICATE_NAME" --timestamp -o runtime "pkg_extract/Payload/git/libexec/git-core/git-imap-send"
/usr/bin/codesign -s "$APPLICATION_CERTIFICATE_NAME" --timestamp -o runtime "pkg_extract/Payload/git/libexec/git-core/git-sh-i18n--envsubst"
/usr/bin/codesign -s "$APPLICATION_CERTIFICATE_NAME" --timestamp -o runtime "pkg_extract/Payload/git/libexec/git-core/git-daemon"
/usr/bin/codesign -s "$APPLICATION_CERTIFICATE_NAME" --timestamp -o runtime "pkg_extract/Payload/git/libexec/git-core/git-remote-http"
/usr/bin/codesign -s "$APPLICATION_CERTIFICATE_NAME" --timestamp -o runtime "pkg_extract/Payload/git/libexec/git-core/git-http-fetch"
/usr/bin/codesign -s "$APPLICATION_CERTIFICATE_NAME" --timestamp -o runtime "pkg_extract/Payload/git/libexec/git-core/git-http-backend"

# Wish / Git Gui is already signed, for notarization we need to re-sign it
/usr/bin/codesign -f -s "$APPLICATION_CERTIFICATE_NAME" --timestamp -o runtime "pkg_extract/Payload/git/share/git-gui/lib/Git Gui.app/Contents/MacOS/Wish"

# Rebuild the pkg
/usr/bin/pkgbuild --identifier com.git.pkg --version "$git_version" --root "pkg_extract/Payload/" --install-location "/usr/local" --component-plist ../git-components.plist "rebuilt.pkg"

# Sign the pkg
/usr/bin/productbuild --package "rebuilt.pkg" --sign "$INSTALLER_CERTIFICATE_NAME" "$new_pkg_filename"

# Create the DMG
rm -rf *.dmg
mkdir disk-image
cp -v "$new_pkg_filename" disk-image/
hdiutil create "git-$git_version.uncompressed.dmg" -fs HFS+ -srcfolder disk-image -volname "Git $git_version" -ov
hdiutil convert -format UDZO -o "$new_dmg_filename" "git-$git_version.uncompressed.dmg"
rm -f "git-$git_version.uncompressed.dmg"

# Sign the DMG
codesign -s "$APPLICATION_CERTIFICATE_NAME" "$new_dmg_filename"

# Delete temp files / folders
rm -f "$pkg_filename"
rm -f "rebuilt.pkg"
rm -rf "pkg_extract"

# Store the Developer credentials
$XCODE_PATH/Contents/Developer/usr/bin/notarytool store-credentials --apple-id "$DEVELOPER_EMAIL" --team-id "$DEVELOPER_TEAM" --password "$DEVELOPER_PASSWORD" git

# Notarize the pkg
$XCODE_PATH/Contents/Developer/usr/bin/notarytool submit "$new_pkg_filename" --keychain-profile "git" --wait
$XCODE_PATH/Contents/Developer/usr/bin/stapler staple "$new_pkg_filename"

# Notarize the dmg
$XCODE_PATH/Contents/Developer/usr/bin/notarytool submit "$new_dmg_filename" --keychain-profile "git" --wait
$XCODE_PATH/Contents/Developer/usr/bin/stapler staple "$new_dmg_filename"

# You can get the  notarize logs using
# $XCODE_PATH/Contents/Developer/usr/bin/notarytool log <submission_id> --keychain-profile "git" 
