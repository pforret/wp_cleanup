#!/bin/bash
PATTERN="<script type='text/javascript' src='https://snippet.adsformarket.com/same.js'></script>"

if [[ "$1" == "" ]] ; then
  # print usage
  echo "Usage: $0 [folder]"
  echo "  with [folder] the root folder of all your websites (e.g. {whatever}/vhosts"
  echo "  start this script in a folder where you can write files"
  echo "  will look for [$PATTERN]"
  exit 0
fi


STARTDIR=$(pwd)
pushd $1

SITES=$STARTDIR/sites.txt
if [[ ! -f "$SITES" ]] ; then
  find . -mindepth 1 -maxdepth 1 -type d > "$SITES"
fi

for SITE in $(cat $SITES) ; do
  BSITE=$(basename "$SITE")
  INFECTED=$STARTDIR/infected.$BSITE.txt
  if [[ ! -f $INFECTED ]]; then
    echo searching $SITE ...
    grep -rl --include=\*.php --include=\*.htm --include=\*.html  "$PATTERN" $SITE > $INFECTED 2> /dev/null
  fi
  NBHACKED=$(wc -l $INFECTED | cut -d' ' -f1)
  if [[ $NBHACKED -gt 0 ]] ; then
    echo "found: $SITE:   $NBHACKED files!"
    for LINE in $(cat $INFECTED) ; do
      FILE="$LINE"
      TFILE="$LINE.tmp"
      OFILE="$LINE.hacked"

      ISIZE=$(wc -c $FILE | cut -d' ' -f1)
      < "$FILE" \
        sed 's|$PATTERN||g' \
        > "$TFILE"
      OSIZE=$(wc -c $TFILE | cut -d' ' -f1)

      if [[ $ISIZE -ne $OSIZE ]] ; then
        # replace by cleaned version
        mv "$FILE" "$OFILE"
        mv "$TFILE" "$FILE"
        echo ".  cleaned $FILE ..."
      else
        # undo cleanup
        rm "$TFILE"
      fi
    done
  fi
done
echo "If the results are good, your can delete the disabled hacked files with 'rm -r $1/*.hacked'" 
popd
