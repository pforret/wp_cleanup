#!/bin/bash
PATTERN="s.src=pl;"

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

remove_from_file(){
  # $1 = file
  # $2 = pattern
  orig_file="$1"
  temp_file="$1.tmp"
  old_file="$1.hacked"

  size1=$(wc -c $orig_file | cut -d' ' -f1)

  < "$orig_file" sed "s|$2||g" > "$temp_file"

  size2=$(wc -c $temp_file | cut -d' ' -f1)

  if [[ $size1 -ne $size2 ]] ; then
    # replace by cleaned version
    mv "$orig_file" "$old_file"
    mv "$temp_file" "$orig_file"
    echo ".  cleaned $orig_file ..."
  else
  # undo  cleanup
    rm "$temp_file"
  fi
}

SITES=$STARTDIR/sites.txt
if [[ ! -f "$SITES" ]] ; then
  find . -mindepth 1 -maxdepth 1 -type d > "$SITES"
fi

for SITE in $(cat $SITES) ; do
  BSITE=$(basename "$SITE")
  INFECTED=$STARTDIR/infected.$BSITE.txt
  if [[ ! -f $INFECTED ]]; then
    echo searching $SITE ...
    grep -rl --include=\*.js --include=\*.json "$PATTERN" $SITE > $INFECTED 2> /dev/null
  fi
  NBHACKED=$(wc -l $INFECTED | cut -d' ' -f1)
  if [[ $NBHACKED -gt 0 ]] ; then
    echo "found: $SITE:   $NBHACKED files!"
    for LINE in $(cat $INFECTED) ; do
      remove_from_file "$LINE" "$PATTERN"
    done
  fi
done
echo "If the results are good, your can delete the disabled hacked files with 'rm -r $1/*.hacked'" 
popd
