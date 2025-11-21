#!/usr/bin/env bash
# Creates an erwic container,
# containing the files: run.sh, erwic.json, <cont_name>.desktop
# Features:
# - run.sh manages the desktop file link to ~/.local/applications
# - run.sh tries to download an icon for the desktop file
# Usage: ./mkerwic.sh dir_name [container_name url]
[ ! -n "$1" ] && exit 1
container_name="${2:-enter_container_name_here}"
url="${3:-enter_url_here}"
mkdir $1
touch "$1/run.sh" "$1/erwic.json" "$1/$container_name.desktop"

run_script=$(cat <<EOF
#!/bin/sh
prefix_dir="\${XDG_CONFIG_HOME:-\$HOME/.config}/vieb/erwic/$1"
[ -n "\$VIEB_CONFIG_FILE" ] && prefix_dir="\$(dirname "\$VIEB_CONFIG_FILE")/erwic/$1"
# run vieb
vieb --config-file="\$prefix_dir/viebrc" --erwic="\$prefix_dir/erwic.json" --datafolder="\$prefix_dir"
EOF
)
boilerplate_json=$(cat <<EOF
{
  "name": "$container_name",
  "apps": [
    {
      "container": "$container_name",
      "url": "$url"
    }
  ]
}
EOF
)
desktop_file=$(cat <<EOF
[Desktop Entry]
Name=Erwic - $container_name
Exec=$(realpath "$1/run.sh")
Terminal=false
Type=Application
Comment=Easily Run Websites In Containers
Categories=Network;WebBrowser;
EOF
)

echo "$run_script" > "$1/run.sh"
echo "$boilerplate_json" > "$1/erwic.json"
echo "$desktop_file" > "$1/$container_name.desktop"
echo "source ../../viebrc" > "$1/viebrc"
ln -s $(realpath "$1/$container_name.desktop") "${XDG_DATA_HOME:-$HOME/.local/share}/applications"
chmod +x "$1/run.sh"

