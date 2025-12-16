-- config.util
local M={}
local _M={}-- Hidden members
-- meta method to convert list of string/numbers into string
_M.m_list_tostring = {
  __tostring = function(t)
    local s = ''
    for k,v in pairs(t) do
      s = s..tostring(v)
    end
    return s
  end
}

---@param root_markers string[]
M.root_path = function(root_markers)
  return root_markers
end

-- Serialize table into string
---@param tbl table The table to serialize
---@return string
M.serialize_table = function(tbl)
  if type(tbl) ~= 'table' then
    return ''
  end
  local ifs='\n'
  local indent='  '
  local elems=0 -- get number of elements in the table
  for _ in pairs(tbl) do elems=elems+1 end

  local result = '{'..ifs
  local c=0
  for k, v in pairs(tbl) do
    c=c+1
    if type(k) == 'string' then
      k = '\''..k..'\''
    end
    k = '['..tostring(k)..']'
    result = result..indent..k..'='
    if type(v) == 'table' then
      result = result..M.serialize_table(v)
    else
      result = result..tostring(v)
    end
    if (c~=elems) then
      result = result..','..ifs
    end
  end
  return result..'\n}'
end

M.run_on_each_file = function(dir, callback)
  -- Expand '~' or relative paths
  dir = vim.fn.expand(dir)

  -- Read directory entries
  local files = vim.fn.readdir(dir)

  for _, file in ipairs(files) do
    local full_path = dir .. '/' .. file

    -- Skip if it's not a file
    if vim.fn.isdirectory(full_path) == 0 then
      callback(dir, file)
    end
  end
end

return M
