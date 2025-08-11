return {
  -- Disable bufferline (tab bar) since you prefer single file
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  
  -- Configure telescope to replace current buffer when opening files
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<CR>"] = function(prompt_bufnr)
              local actions = require("telescope.actions")
              local action_set = require("telescope.actions.set")
              
              -- Close current buffer before opening new one (if not dashboard)
              local current_buf = vim.api.nvim_get_current_buf()
              local current_name = vim.api.nvim_buf_get_name(current_buf)
              
              -- Don't close if it's the dashboard or a special buffer
              if current_name ~= "" and not string.match(current_name, "snacks_dashboard") then
                vim.schedule(function()
                  vim.api.nvim_buf_delete(current_buf, { force = false })
                end)
              end
              
              action_set.select(prompt_bufnr, "default")
              actions.close(prompt_bufnr)
            end,
          },
          n = {
            ["<CR>"] = function(prompt_bufnr)
              local actions = require("telescope.actions")
              local action_set = require("telescope.actions.set")
              
              -- Close current buffer before opening new one (if not dashboard)
              local current_buf = vim.api.nvim_get_current_buf()
              local current_name = vim.api.nvim_buf_get_name(current_buf)
              
              -- Don't close if it's the dashboard or a special buffer
              if current_name ~= "" and not string.match(current_name, "snacks_dashboard") then
                vim.schedule(function()
                  vim.api.nvim_buf_delete(current_buf, { force = false })
                end)
              end
              
              action_set.select(prompt_bufnr, "default")
              actions.close(prompt_bufnr)
            end,
          },
        },
      },
    },
  },
}