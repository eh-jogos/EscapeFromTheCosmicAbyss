#!/bin/zsh

mkdir butler
cd butler

# -L follows redirects
# -O specifies output name
curl -L -o butler_linux.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
unzip butler_linux.zip
rm butler_linux.zip
# GNU unzip tends to not set the executable bit even though it's set in the .zip
chmod +x butler
# just a sanity check run (and also helpful in case you're sharing CI logs)
./butler -V

curl -L -o butler_windows.zip https://broth.itch.ovh/butler/windows-amd64/LATEST/archive/default
unzip butler_windows.zip
rm butler_windows.zip
