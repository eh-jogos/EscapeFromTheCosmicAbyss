#!/bin/zsh
project_settings="project.godot"
export_configs="export_presets.cfg"
export_output=$1
game_version=$2

if [[ -z $game_version ]]
then
   	game_version=$(cat $project_settings | grep "^config/version" | cut -d'=' -f2)
	game_version=$(sed -e 's/^"//' -e 's/"$//' <<< $game_version)
fi
echo "Exporting $game_version"


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
	filename=$(sed -e 's/^"//' -e 's/"$//' <<< ${export_paths[i]})
	# This is to accept other modifiers in case you want
	# to have separate scripts for building steam releases
	# or building itch.io releases. Just add them as cases below
	case $export_output in
		*)
			./build_standalone_releases.sh $game_version $profile $filename
			;;
	esac
done