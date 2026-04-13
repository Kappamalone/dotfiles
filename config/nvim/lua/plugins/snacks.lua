-- Only show manually set marks (a–z, A–Z)
local function manual_marks_picker()
  Snacks.picker.marks({
    transform = function(item)
      if type(item.text) == "string" and item.text:match("^[a-zA-Z]%s") then
        return item
      end
      return false -- drop implicit marks
    end,
  })
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>fe", false },
      { "<leader>fE", false },
      { "<leader>e",  false },
      { "<leader>E",  false },

      { "<leader>sm", manual_marks_picker, desc = "Marks (manual only)" },
    },
  },
}
