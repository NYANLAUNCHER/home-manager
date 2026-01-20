return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function ()
    require('nvim-treesitter.configs').setup({
      ensure_installed = { 'rust', 'c', 'cpp', 'lua', 'nix', 'zig', 'glsl', 'wgsl', 'vim', 'vimdoc', 'query' },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = false },
      autotag = {
        enable = true,
      },
    })
  end
}
