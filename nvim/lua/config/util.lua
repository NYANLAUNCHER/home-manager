-- config.util
local M={}
local _M={}-- Hidden members
-- meta method to convert list of string/numbers into string
_M.m_list_tostring = {
  __tostring = function(t)
    local s = ""
    for k,v in pairs(t) do
      s = s..tostring(v)
    end
    return s
  end
}

-- Serialize table into string
-- @param tbl (table) The table to be converted.
-- @return: Returns a string representation of the table.
function M.serialize_table(tbl)
  local result = "{"
  for k, v in pairs(tbl) do
    result = result .. tostring(k) .. "="
    if type(v) == "table" then
      result = result .. M.serialize_table(v)
    else
      result = result .. tostring(v)
    end
    result = result .. ", "
  end
  return result .. "}"
end
-- List all files in a directory (non-recursively)
--[[
function M.list_files(directory)
  local i, t = 0, {}
  local pfile = assert(io.popen(("find '%s' -maxdepth 1 -print0"):format(directory), 'r'):read('*a'))
  local s = pfile:read('*a')
  pfile:close()
  for filename in s:gmatch('[^\0]+') do
    i = i+1
    t[i] = filename
    print(tostring(filename))
  end
  return t
end
]]

return M
