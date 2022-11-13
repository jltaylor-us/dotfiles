#!/bin/bash -e

if test $# -ne 1; then
    echo "Usage: $0 <dir>"
    echo "Removes .DS_Store files in <dir>, then creates a compressed disk image"
    echo "and a file containing the results of checksums.sh on the disk contents"
    exit 1
fi

source=${1%/}
if ! test -d "$source"; then
    echo "\"$source\" is not a directory"
    exit 2
fi

echo "Removing .DS_Store files"
find "$source" -name .DS_Store -exec rm {} \;

tmpdir=$(mktemp -d)

echo "Creating disk image in temporary directory $tmpdir"
hdiutil create -srcfolder "$source" -format UDSB "$tmpdir/dmg.sparsebundle" > "$tmpdir/log"
hdiutil convert "$tmpdir/dmg.sparsebundle" -format UDZO -o "$tmpdir/dmg.dmg" >> "$tmpdir/log"

echo "Mounting disk image"
hdiutil attach "$tmpdir/dmg.dmg" -mountpoint "$tmpdir/mnt" >> "$tmpdir/log"
echo "Computing checksums"
checksums.sh "$tmpdir/mnt" | sort > "$tmpdir/cs.txt"
echo "Unmounting disk image"
hdiutil detach "$tmpdir/mnt" >> "$tmpdir/log"

echo "Copying into place"
cp "$tmpdir/dmg.dmg" "${source}.dmg"
cp "$tmpdir/cs.txt" "${source}.dmg checksums.txt"
echo "Verifying copies"
diff "$tmpdir/dmg.dmg" "${source}.dmg"
diff "$tmpdir/cs.txt" "${source}.dmg checksums.txt"

echo "cleaning up"
rm -r "$tmpdir"
