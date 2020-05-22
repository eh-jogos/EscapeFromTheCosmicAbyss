#!/bin/zsh
export_configs="export_presets.cfg"
version=$1

function getProperty {
   prop_key=$1
   prop_value=$(cat $export_configs | grep $prop_key | cut -d'=' -f2)
   echo $prop_value
}

export_profiles=(${=$(getProperty "^name")})
echo "Going to Export the following profiles: $export_profiles"
export_paths=(${=$(getProperty "^export_path")})

length=${#export_profiles[@]}
for ((i = 1; i <= $length; i++));
do
	profile=${export_profiles[i]}
	# This is to accept other modifiers in case you want
	# to have separate scripts for building steam releases
	# or building itch.io releases. Just add them as cases below
	case $2 in
		*)
			./build_standalone_releases.sh $version $profile
			;;
	esac
done