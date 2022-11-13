#!/bin/bash

if [ $# -ne 1 ]; then
  echo "usage: $0 <dir>"
  exit 1
fi

if [ ! -d "$1" ]; then
  echo "not a directory: $1"
  exit 2
fi

olddir=`pwd`
cd "$1"

caffeinate find . \
 -name .fseventsd -prune -o -name .Spotlight-\* -prune -o -name .Trashes -prune -o \
 -type f -not -name .DS_Store -exec md5 {} \;

cd "$olddir"
