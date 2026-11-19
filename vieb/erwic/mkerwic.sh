#!/usr/bin/env bash
# Creates an erwic (Easily Run Websites In Containers) app for vieb:
#   $VIEB_ERWIC_DIR/<dir_name>/{run.sh,erwic.json,<container_name>.desktop}
# and links the desktop file into ~/.local/share/applications.
# The app's datafolder is its own directory, and it uses the normal viebrc.
#
# VIEB_ERWIC_DIR defaults to ${XDG_DATA_HOME:-~/.local/share}/vieb/erwic, so it
# works when the vieb config itself lives in the (read-only) nix store.
#
# Usage: mkerwic.sh dir_name [container_name url]
# The nix package installs this as `vieb-mkerwic`.
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $(basename "$0") dir_name [container_name url]" >&2
  exit 1
fi
container_name="${2:-enter_container_name_here}"
url="${3:-enter_url_here}"

erwic_dir="${VIEB_ERWIC_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/vieb/erwic}"
app_dir="$erwic_dir/$1"
apps_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

if [ -e "$app_dir" ]; then
  echo "$app_dir already exists" >&2
  exit 1
fi
mkdir -p "$app_dir" "$apps_dir"

cat > "$app_dir/run.sh" <<'EOF'
#!/bin/sh
dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
exec vieb --erwic="$dir/erwic.json" --datafolder="$dir"
EOF
chmod +x "$app_dir/run.sh"

cat > "$app_dir/erwic.json" <<EOF
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

cat > "$app_dir/$container_name.desktop" <<EOF
[Desktop Entry]
Name=Erwic - $container_name
Exec=$app_dir/run.sh
Terminal=false
Type=Application
Comment=Easily Run Websites In Containers
Categories=Network;WebBrowser;
EOF
ln -sf "$app_dir/$container_name.desktop" "$apps_dir/"

echo "Created $app_dir"
