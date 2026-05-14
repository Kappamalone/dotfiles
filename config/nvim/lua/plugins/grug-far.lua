return {
  "MagicDuck/grug-far.nvim",
  keys = {
    {
      "<leader>sr",
      function()
        require("grug-far").open({
          prefills = {
            search = vim.fn.expand("<cword>"),
            paths  = vim.fn.expand("%"),
          },
        })
      end,
      desc = "Grug far (current file)",
    },
  },
}
