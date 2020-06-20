#!/bin/zsh
project_settings="project.godot"
export_configs="export_presets.cfg"
game_version=$(cat $project_settings | grep "^config/version" | cut -d'=' -f2)
game_version=$(sed -e 's/^"//' -e 's/"$//' <<< $game_version)
project_path=$(pwd)
base_builds_path="$(dirname $project_path)/GameBuilds/$game_version/Release"
itch_game_adress=eh-jogos/cosmicabyss

builds_to_push=$1

if [[ -z $builds_to_push || $builds_to_push = "all" ]]
then
	builds_to_push="all"
elif [[ $builds_to_push = "linux" ]]
then
	builds_to_push="linux"
elif [[ $builds_to_push = "win" || $builds_to_push = "windows" ]]
then
	builds_to_push="win"
elif [[ $builds_to_push = "mac" || $builds_to_push = "osx" ]]
then
	builds_to_push="osx"
else
	echo "Unrecognized option for builds_to_push: $builds_to_push | changing to 'all'"
	builds_to_push=false
fi

# In the future, maybe try to use the same folder structure you use for steam, but add some ignores to separate the versions
# for OSX you can just send the zip directly
function push_linux {
	butler push --userversion=$game_version $base_builds_path/CosmicAbyssLinux32 $itch_game_adress:linux32
	butler push --userversion=$game_version $base_builds_path/CosmicAbyssLinux64 $itch_game_adress:linux64
}

function push_windows {
	butler push --userversion=$game_version $base_builds_path/CosmicAbyssWindows32 $itch_game_adress:windows32
	butler push --userversion=$game_version $base_builds_path/CosmicAbyssWindows64 $itch_game_adress:windows64
}

function push_osx {
	butler push --userversion=$game_version $base_builds_path/CosmicAbyssOSX $itch_game_adress:osx-universal
}


case $builds_to_push in
	"linux")
		push_linux
		;;
	"win")
		push_windows
		;;
	"osx")
		push_osx
		;;
	*)
		push_linux
		push_windows
		push_osx
		;;
esac