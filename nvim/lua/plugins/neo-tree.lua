return {
  -- Disable explorer auto-open when opening a directory
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        replace_netrw = false,
      },
    },
  },
}
