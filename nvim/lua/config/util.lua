-- @module util
-- @alias M
local M={}

-- Serialize a table
-- @param tbl (table) The table to be converted.
-- @return: Returns a string representation of the table.
function M.tableToString(tbl)
  local result = "{"
  for k, v in pairs(tbl) do
    result = result .. tostring(k) .. "="
    if type(v) == "table" then
      result = result .. table_to_string(v)
    else
      result = result .. tostring(v)
    end
    result = result .. ", "
  end
  return result .. "}"
end

-- list of binary filetypes
M.binary_ft = {
}

-- @param bufnr (int) the buffer number to check
function M.is_buf_binary(bufnr)
  local ft=vim.filetype.match({buf = bufnr or 0})
  if M.binary_ft[ft] then
      return true
  end
  return false
end

-- `vim.api` Aliases: {{{
-- Functions:
M.get_curr_buf = function(...) vim.api.nvim_get_current_buf(...) end
M.get_bufname = function(...) vim.api.nvim_buf_get_name(...) end
-- Variables
--}}}
return M
