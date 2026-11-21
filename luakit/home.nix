{ config, pkgs, lib, ... }:
{
  home.sessionVariables = {
    LUAKIT_LUA_PATH = "$(realpath -e $(readlink $(dirname $(which luakit)))/../share/luakit/lib 2> /dev/null)";
  };
  home.packages = (with pkgs; [
    luakit
  ]);
}
