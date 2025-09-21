#!/usr/bin/env bash
set -e

if [[ "$#" != 2 && "$#" != 3 ]]; then
    echo "Usage: $(basename "$0") <app-file> <background-png> [--no-gui]"
    exit 1
fi

appFile="$1"
backgroundFile="$2"

appFileName="$(basename "$appFile")"
backgroundFileName="$(basename "$backgroundFile")"
volName="CovScript"

echo ":: [Stage 1] Creating read/write precursor dmg"
dmgBuildDir=".$$.install"
rwDmg="covscript-precursor.dmg"

rm -f "${volName}.dmg"
mkdir "$dmgBuildDir"
mkdir "$dmgBuildDir/.hidden"
(cd "$dmgBuildDir" && ln -s /Applications .)
cp -r "$appFile" "$dmgBuildDir"
cp "$backgroundFile" "$dmgBuildDir/.hidden"
chflags hidden "$dmgBuildDir/.hidden"

hdiutil create -volname "$volName" -srcfolder "$PWD/$dmgBuildDir" -ov -format UDRW -fs HFS+ "$rwDmg"

if [[ "$3" != "--no-gui" ]]; then

echo ":: [Stage 2] Mounting precursor dmg"
mountPoint=$(hdiutil attach -readwrite -noverify -noautoopen "$rwDmg" | grep Volumes | awk '{print $3}')
sleep 2

echo ":: [Stage 2] Applying background: 600x400"
backgroundWidth=600
backgroundHeight=400

topLeftX=100
topLeftY=100
let bottomRightX=$backgroundWidth+$topLeftX
let bottomRightY=$backgroundHeight+$topLeftY
let centery=($backgroundHeight/2)-32

let centerXAppFile=$backgroundWidth/4
let centerXApplications=$backgroundWidth/4*3

echo ":: [Stage 2] Running AppleScript"
osascript <<EOF
tell application "Finder"
    tell disk "$volName"
       set current view of container window to icon view
       set theViewOptions to the icon view options of container window
       set icon size of theViewOptions to 128
       set background picture of theViewOptions to POSIX file "/Volumes/$volName/.hidden/$backgroundFileName"
       open
       set toolbar visible of container window to false
       set statusbar visible of container window to false
       set the extension hidden of item "$appFileName" to true
       set the bounds of container window to {$topLeftX, $topLeftY, $bottomRightX, $bottomRightY}
       set position of item "$appFileName" of container window to {$centerXAppFile, $centery}
       set position of item "Applications" of container window to {$centerXApplications, $centery}
       close
       open
       update without registering applications
       delay 2
       close container window
    end tell
end tell
EOF

echo ":: [Stage 2] Detaching"
diskutil eject "$mountPoint" >/dev/null
sleep 2

fi

echo ":: [Stage 3] Creating the final read-only dmg"
hdiutil convert "$rwDmg" -format UDZO -ov -o "${volName}.dmg"

echo ":: [Stage 4] Cleaning up"
rm -rf "$dmgBuildDir"
rm -f "$rwDmg"

echo ":: Done, created ${volName}.dmg"
