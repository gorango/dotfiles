return {
  "echasnovski/mini.nvim",
  version = false,
  config = function()
    require("mini.map").setup({
      integrations = nil,
      symbols = {
        -- `:h MiniMap.config` for specification
        -- `:h MiniMap.gen_encode_symbols` for pre-built ones
        encode = nil,
        scroll_line = "╌", -- '□',
        scroll_view = "┊", -- '╎', '┋', '┊', '·', '︱', '︲'
      },

      -- Window options
      window = {
        focusable = true,
        side = "right",
        show_integration_count = true,
        width = 7,
        winblend = 25,
      },
    })

    vim.keymap.set("n", "<Leader>mc", MiniMap.close)
    vim.keymap.set("n", "<Leader>mf", MiniMap.toggle_focus)
    vim.keymap.set("n", "<Leader>mo", MiniMap.open)
    vim.keymap.set("n", "<Leader>mr", MiniMap.refresh)
    vim.keymap.set("n", "<Leader>ms", MiniMap.toggle_side)
    vim.keymap.set("n", "<Leader>mt", MiniMap.toggle)

    -- MiniMap.open()
    MiniMap.refresh({
      symbols = {
        encode = MiniMap.gen_encode_symbols.dot("4x2"),
      },
    })
  end,
}

