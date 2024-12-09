-- Set lualine as statusline
return {
	"nvim-lualine/lualine.nvim",
	config = function()
		-- Adapted from: https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/themes/onedark.lua
		local colors = {
			blue = "#8ba4b0",
			green = "#8a9a7b",
			purple = "#a292a3",
			cyan = "#8ea4a2",
			red1 = "#c4746e",
			red2 = "#be5046",
			yellow = "#e5c07b",
			fg = "#DCD7BA",
			bg = "#1F1F28",
			gray1 = "#54546D",
			gray2 = "#2A2A37",
			gray3 = "#363646",
		}

		local kanagawa_paper = {
			normal = {
				a = { fg = colors.bg, bg = colors.red1, gui = "bold" },
				b = { fg = colors.fg, bg = colors.gray3 },
				c = { fg = colors.fg, bg = colors.bg },
			},
			command = { a = { fg = colors.bg, bg = colors.yellow, gui = "bold" } },
			insert = { a = { fg = colors.bg, bg = colors.blue, gui = "bold" } },
			visual = { a = { fg = colors.bg, bg = colors.purple, gui = "bold" } },
			terminal = { a = { fg = colors.bg, bg = colors.cyan, gui = "bold" } },
			replace = { a = { fg = colors.bg, bg = colors.red1, gui = "bold" } },
			inactive = {
				a = { fg = colors.gray1, bg = colors.bg, gui = "bold" },
				b = { fg = colors.gray1, bg = colors.bg },
				c = { fg = colors.gray1, bg = colors.gray2 },
			},
		}

		--	local kanagawa_paper = require("themes.kanagawa-paper")
		-- Import color theme based on environment variable NVIM_THEME
		local env_var_nvim_theme = "kanagawa_paper"

		-- Define a table of themes
		local themes = {
			kanagawa_paper = kanagawa_paper,
		}

		local mode = {
			"mode",
			fmt = function(str)
				-- return ' ' .. str:sub(1, 1) -- displays only the first character of the mode
				return " " .. str
			end,
		}

		local filename = {
			"filename",
			file_status = true, -- displays file status (readonly status, modified status)
			path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
		}

		local hide_in_width = function()
			return vim.fn.winwidth(0) > 100
		end

		local diagnostics = {
			"diagnostics",
			sources = { "nvim_diagnostic" },
			sections = { "error", "warn" },
			symbols = { error = " ", warn = " ", info = " ", hint = " " },
			colored = false,
			update_in_insert = false,
			always_visible = false,
			cond = hide_in_width,
		}

		local diff = {
			"diff",
			colored = false,
			symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
			cond = hide_in_width,
		}

		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = themes[env_var_nvim_theme], -- Set theme based on environment variable
				-- Some useful glyphs:
				-- https://www.nerdfonts.com/cheat-sheet
				--        
				section_separators = { left = "", right = "" },
				component_separators = { left = "", right = "" },
				disabled_filetypes = { "alpha", "neo-tree", "Avante" },
				always_divide_middle = true,
			},
			sections = {
				lualine_a = { mode },
				lualine_b = { "branch" },
				lualine_c = { filename },
				lualine_x = {
					diagnostics,
					diff,
					{ "encoding", cond = hide_in_width },
					{ "filetype", cond = hide_in_width },
				},
				lualine_y = { "location" },
				lualine_z = { "progress" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { { "location", padding = 0 } },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {
				lualine_a = { "buffers" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},

			extensions = { "fugitive" },
		})
	end,
}
