#!/bin/zsh
export_configs="export_presets.cfg"
godot_version="32"
base_builds_path="../GameBuilds/"
project_name="CosmicAbyss"
version=$1
debug=$2

fpath=( ~/.zfunc "${fpath[@]}" )
autoload -Uz godot

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
	echo "###########################################################"
	profile=${export_profiles[i]}
	unquoted_profile=$(sed -e 's/^"//' -e 's/"$//' <<< $profile)
	unquoted_filename=$(sed -e 's/^"//' -e 's/"$//' <<< ${export_paths[i]})
	final_path_release=$base_builds_path$version"/Release/"$project_name$unquoted_profile"/"
	final_path_debug=$base_builds_path$version"/Debug/"$project_name$unquoted_profile"/"
	
	echo "Exporting $unquoted_profile Release to $final_path_release"
	mkdir -p $final_path_release
	godot godot_version --export $unquoted_profile $final_path_release$unquoted_filename
	
	echo "Exporting $unquoted_profile Debug to $final_path_debug"
	mkdir -p $final_path_debug
	godot godot_version --export-debug $unquoted_profile $final_path_debug$unquoted_filename

	echo "Exporting $unquoted_profile Finished"
	echo "###########################################################"
done