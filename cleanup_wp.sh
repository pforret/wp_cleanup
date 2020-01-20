#!/bin/bash
if [[ "$1" == "" ]] ; then
	# print usage
	echo "Usage: $0 [folder]"
	echo "	with [folder] the root folder of all your websites (e.g. {whatever}/vhosts"
	echo "	start this script in a folder where you can write files"
	echo "	it will reinstall as much as possible from a fresh Wordpress download"
	exit 0
fi

STARTDIR=$(pwd)

if [[ ! -f "wordpress/wp-config-sample.php" ]] ; then
	echo "First download clean install version of Wordpress"
	WP_URL="https://wordpress.org/latest.zip"
	WP_ZIP=$(basename $WP_URL)
	wget -q $WP_URL
	if [[ -f $WP_ZIP ]] ; then
		du -h $WP_ZIP
		nbunzip=$(unzip $WP_ZIP | wc -l)
		echo "$nbunzip files in clean install of WP"
	else
		echo "Download did not work. Are you sure you have write perlission in this folder [$(pwd)]?"
		exit 1
	fi
fi

overwrite(){
	nbrsync=$(rsync -rva "$1" "$2" | wc -l)
	echo "$nbrsync files written to [$2]"
}

for WP in $(find "$1" -type f -name wp-config.php) ; do
	WPROOT=$(dirname "$WP")
	echo "## FOLDER $WPROOT"
	overwrite "wordpress/wp-admin"	"$WPROOT/"
	overwrite "wordpress/wp-includes"	"$WPROOT/"
	overwrite "wordpress/wp-content/themes"	"$WPROOT/wp-content/"
	overwrite "wordpress/wp-content/plugins/akismet"	"$WPROOT/wp-content/plugins/"
done

