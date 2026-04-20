-- Add/change/delete surrounding pairs. Stays in the mini.* family already used
-- here (mini.ai, mini.pairs, mini.icons), so no extra framework to learn.
return {
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "sa",            -- visual or normal + motion, e.g. saiw"
        delete = "sd",         -- sd"
        find = "sf",
        find_left = "sF",
        highlight = "sh",
        replace = "sr",        -- sr"'
        update_n_lines = "sn",
      },
    },
  },
}
