#!/bin/bash
if [[ "$1" == "" ]] ; then
  # print usage
  echo "Usage: $0 [folder]"
  echo "  with [folder] the root folder of all your websites (e.g. {whatever}/vhosts"
  echo "  start this script in a folder where you can write files"
  echo "  it will reinstall as much as possible from a fresh Wordpress download"
  exit 0
fi

