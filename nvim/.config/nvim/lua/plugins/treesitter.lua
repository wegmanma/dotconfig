-- Highlight, edit, and navigate code
return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    dependencies = {
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
	},
},
    config = function()
    require('nvim-treesitter').setup()
  end,
  }
