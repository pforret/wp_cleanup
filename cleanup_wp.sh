#!/bin/bash
if [[ "$1" == "" ]] ; then
	# print usage
	echo "Usage: $0 [folder] [mode]"
	echo "	[folder]: root folder of all your websites (e.g. {whatever}/vhosts or of 1 specific WP installation"
	echo "	[mode]: 'soft' (default) : test for infection first, ask confirmation for each WP, and 'hard': always fix"
	echo "	always start this script in a folder where you can write files (it will download and use a fresh WP copy)"
	exit 0
fi

MODE="soft"
force=0
if [[ "$2" == "hard" -o "$2" == "HARD" ]] ; then
	MODE="hard"
	force=1
fi

## define handy function for later

confirm() { (($force)) && return 0; read -p "$1 [y/N] " -n 1; echo " "; [[ $REPLY =~ ^[Yy]$ ]];}

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
  else
  # undo  cleanup
    rm "$temp_file"
  fi
}

find_suspects(){
	# $1 = folder
	# $2 = pattern to look for
	### what we are trying to detect:
	##  var pl = String.fromCharCode(104,116,116,112,115,58,47,47,115,110,105,112,112,101,116,46,97,100,115,102,111,114,109,97,114,107,101,116,46,99,111,109,47,115,97,109,101,46,106,115,63,118,61,51); s.src=pl; 
	#pattern="String.fromCharCode(104,116,116,112"
	pattern="$2"
	if [[ "$pattern" == "" ]] ; then
		# used for JS injection hacks
		pattern="s.src=pl;"	
	fi
	nbsuspect=$(grep -rl "$pattern" "$1" | wc -l)
	echo $nbsuspect
}

overwrite_folder(){
	# e.g. $1 = <fresh WP>/wp-content/plugins
	# e.g. $2 = <hacked WP>/wp-content/
	source="$1"
	bname=$(basename "$1")
	destin="$2/$bname"
	nbinfected=$(find_suspects "$destin")
	if [[ $MODE == "force" -o $nbinfected -gt 0 ]] ; then
		echo ". overwrite [$destin] with fresh WP files"
		nbrsync=$(rsync -rva "$1" "$2" | wc -l)
		echo ". $nbrsync files overwritten!"
	fi
}

replace_folder(){
	# e.g. $1 = <fresh WP>/wp-content/plugins
	# e.g. $2 = <hacked WP>/wp-content/
	source="$1"
	bname=$(basename "$1")
	destin="$2/$bname"
	nbinfected=$(find_suspects "$destin")
	# move existing folder to new, unused name
	if [[ -d "$destin" -a ! -d "${destin}-hacked" ]] ; then
		echo ". move hacked files to [${destin}-hacked]"
		mv "$destin" "${destin}-hacked"
	fi
	# write folder with clean, original files
	if [[ $MODE == "force" -o $nbinfected -gt 0 ]] ; then
		echo ". replace [$destin] with fresh WP files"
		nbrsync=$(rsync -rva "$1" "$2" | wc -l)
		echo ". $nbrsync files written!"
	fi
}

list_subdirs(){
	find "$1" -type d -mindepth 1 -maxdepth 1 \
	| while read folder; do
		basename "$folder"
	done 
}
#########################################################################################################
## first check if fresh installation of Wordpress is present
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

# then find all Wordpress installations and go through them
find "$1" -type f -name wp-config.php 2> /dev/null \
| while read file ; do
	WPROOT=$(dirname "$file")
	echo "## WORDPRESS: [$WPROOT]"
	if confirm "## Check this Wordpress installation?" ; then
		echo "## $(find_suspects $WPROOT) suspect files"
		overwrite_folder "wordpress/wp-admin"	"$WPROOT/"
		overwrite_folder "wordpress/wp-includes"	"$WPROOT/"

		installed_themes=$(list_subdirs "$WPROOT/wp-content/themes")
		replace_folder "wordpress/wp-content/themes"	"$WPROOT/wp-content/"
		echo "! don't forget to reinstall the following themes (or at least the one you used)"
		echo $installed_themes

		installed_plugins=$(list_subdirs "$WPROOT/wp-content/plugins")
		replace_folder "wordpress/wp-content/plugins"	"$WPROOT/wp-content/"
		echo "! don't forget to reinstall the following plugins, if you used them"
		echo $installed_plugins
	fi
done

