return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function ()
    require('nvim-treesitter').setup()
    require('nvim-treesitter').install({ 'rust', 'c', 'cpp', 'lua', 'nix', 'zig', 'glsl', 'wgsl', 'vim', 'vimdoc', 'query' }):wait(300000)
  end
}
