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
	wget https://wordpress.org/latest.zip
	unzip latest.zip
fi

overwrite(){
	nbrsync=$(rsync -rva "$1" "$2" | wc -l)
	echo "$nbrsync files written to [$2]"
}

for WP in $(find "$1" -type f -name wp-config.php) ; do
	WPROOT=$(dirname "$WP")
	overwrite "wordpress/wp-admin"	"$WPROOT/"
	overwrite "wordpress/wp-includes"	"$WPROOT/"
	overwrite "wordpress/wp-content/themes"	"$WPROOT/wp-content/"
	overwrite "wordpress/wp-content/plugins/akismet"	"$WPROOT/wp-content/plugins/"
done

