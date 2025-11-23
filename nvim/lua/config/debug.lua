-- @module debug
-- @alias M
local M={
  -- keymap related debugging
  keymap = {
    export_path = vim.fn.stdpath("config").."/keymaps.txt"
  }
}

-- User Commands
vim.api.nvim_create_user_command("ExportKeymaps", function() d.keymap:export() end, {})

-- Export keymaps to txt file
-- @param opts.filepath (string) defaults to ~/.config/nvim/keymaps_export.txt
function M.keymap:export()
  local filepath = self.export_path or "./nvim_keymaps.txt"
  local file = io.open(filepath, "w")

  if not file then
    print("Could not write file: " .. filepath)
    return
  end

  local modes = {
    n = "Normal",
    i = "Insert",
    v = "Visual",
    x = "Visual Block",
    c = "Command",
    t = "Terminal",
  }

  for mode, mode_name in pairs(modes) do
    file:write("=== " .. mode_name .. " (" .. mode .. ") ===\n")
    local maps = vim.api.nvim_get_keymap(mode)
    for _, m in ipairs(maps) do
      file:write(string.format("%s → %s   (opts: %s)\n",
        m.lhs,
        m.rhs or "N/A",
        m.desc or ""
      ))
    end
    file:write("\n")
  end

  file:close()
  print("Keymaps exported to " .. filepath)
end

return M
