return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_ignore_patterns = { "node_modules/", "vendor/", ".git/" },
      layout_config = {
        horizontal = {
          preview_width = 0.6,
        },
      },
    },
  },
  keys = {
    { "<leader>p", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>g", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
  },
}