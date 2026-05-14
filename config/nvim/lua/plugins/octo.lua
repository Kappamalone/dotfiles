return {
  "pwntester/octo.nvim",
  commit = "c14f5b6ee92f0b2717efd525211bcb6cebf03fa6",
  keys = {
    -- disable all of lazyvim's default bindings
    { "<leader>gi", false },
    { "<leader>gI", false },
    { "<leader>gp", false },
    { "<leader>gP", false },
    { "<leader>gr", false },
    { "<leader>gS", false },

    { "<leader>Gm", "<cmd>Octo search author:@me is:pr is:open<cr>", desc = "Github: my open prs"}
    -- create pr from current branch?
    -- make binding for prs requested by me
    -- NOTE: do a pr review using octo next time and compare workflow to gh.nvim
    -- obvious differences:
    -- octo.nvim is more streamlined, easeir to use
    -- gh.nvim lets me review commit by commit
    --
    -- gh.nvim is superior for addressing comments too

  },
  opts = {
    default_to_projects_v2 = false,
    github_hostname = "github-fw.tesla.com",
  },
}
