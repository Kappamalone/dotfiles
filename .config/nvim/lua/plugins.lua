local fn = vim.fn

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

vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerSync
  augroup end
]]

local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float { border = "rounded" }
        end,
    },
}

-- Install your plugins here
-- Run :PackerSync to download and install
return packer.startup(function(use)
    -- Setup
    use "wbthomason/packer.nvim"
    use "nvim-lua/plenary.nvim"

    -- LSP and Coq 
    use "williamboman/nvim-lsp-installer"
    use 'neovim/nvim-lspconfig' 
    use 'ms-jpq/coq_nvim'
    use 'ms-jpq/coq.artifacts'

    -- Misc
    use "kyazdani42/nvim-web-devicons"
    use "kyazdani42/nvim-tree.lua"
    use "nvim-telescope/telescope.nvim"
    use 'ggandor/lightspeed.nvim'
    
    -- Firenvim
    use "glacambre/firenvim"
    run = function() vim.fn['firenvim#install'](0) end

    -- Colorschemes
    use "ellisonleao/gruvbox.nvim"
    use "sainnhe/gruvbox-material"

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)

