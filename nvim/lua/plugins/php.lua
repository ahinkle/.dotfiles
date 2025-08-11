return {
  -- PHP LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000,
              },
            },
          },
        },
      },
    },
  },

  -- Treesitter for PHP
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "php",
        "lua",
        "json",
        "html",
        "css",
        "javascript",
        "typescript",
        "bash",
        "markdown",
        "yaml",
      },
    },
  },

  -- Mason for PHP tools
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "intelephense",
        "php-cs-fixer",
        "phpstan",
      },
    },
  },
}