#!/bin/bash
if [[ "$1" == "" ]] ; then
	# print usage
	echo "Usage: $0 [folder]"
	echo "	with [folder] the root folder of all your websites (e.g. {whatever}/vhosts"
	echo "	start this script in a folder where you can write files"
	echo "	it will reinstall as much as possible from a fresh Wordpress download"
	exit 0
fi

if [[ ! -f "wordpress/wp-config-sample.php" ]] ; then
	WP_URL="https://wordpress.org/latest.zip"
	WP_ZIP=$(basename $WP_URL)
	echo "DOWNLOAD: clean install version of Wordpress: $WP_URL"
	wget -q $WP_URL
	if [[ ! -f $WP_ZIP ]] ;  then
		echo "Download did not work. Are you sure you have write permission in this folder [$(pwd)]?"
		exit 1
	fi
	du -h $WP_ZIP
	nbunzip=$(unzip $WP_ZIP | wc -l)
	if [[ ! -f "wordpress/wp-config-sample.php" ]] ;  then
		echo "Unzip did not work. Are you sure you have write permission in this folder [$(pwd)]?"
		exit 1
	fi
fi
nbfiles=$(find wordpress/ -type f | wc -l)
echo "WORDPRESS: $nbfiles files in clean install of WP (Jan 2020: 1930 files)"

overwrite(){
	nbsource=$(find "$1" -type f | wc -l)
	nbinfected=$(grep -rl "String.fromCharCode" "$2" | wc -l)
	if [[ $nbinfected -gt 0 ]] ; then
		echo " ! found $nbinfected suspect files in [$(basename $1)]"
		echo " - $nbsource files in clean source]"
		nbrsync=$(rsync -rva "$1" "$2" | wc -l)
		echo " - $nbrsync files written [$1] >> [$2]"
	fi
}

find "$1" -type f -name wp-config.php 2> /dev/null \
| while read line ; do
	WPROOT=$(dirname "$line")
	echo "## FOLDER $WPROOT"
	overwrite "wordpress/wp-admin"	"$WPROOT/"
	overwrite "wordpress/wp-includes"	"$WPROOT/"
	#overwrite "wordpress/wp-content/themes"	"$WPROOT/wp-content/"
	#overwrite "wordpress/wp-content/plugins/akismet"	"$WPROOT/wp-content/plugins/"
done

