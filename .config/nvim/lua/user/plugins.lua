local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system {
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	}
	print "Installing packer close and reopen Neovim..."
	vim.cmd [[packadd packer.nvim]]
end

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init {
	display = {
		open_fn = function()
			return require("packer.util").float { border = "rounded" }
		end,
	},
}

-- Run :PackerSync to install plugins
return packer.startup(function(use)
    -- Setup
	use "wbthomason/packer.nvim"
	use "nvim-lua/plenary.nvim"
    
    -- LSP
	use "neovim/nvim-lspconfig"
	use "williamboman/nvim-lsp-installer"
   	use 'ms-jpq/coq_nvim'
   	use 'ms-jpq/coq.artifacts'


    -- Misc
	use "nvim-telescope/telescope.nvim"
	use "nvim-treesitter/nvim-treesitter"
	use "kyazdani42/nvim-web-devicons"
	use "kyazdani42/nvim-tree.lua"
	use "windwp/nvim-autopairs"
	use "akinsho/toggleterm.nvim"
	use "lewis6991/impatient.nvim"
    use "Pocco81/AutoSave.nvim"

    -- Theme
	use "sainnhe/gruvbox-material"

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
