return {
  {
    'nvim-mini/mini.splitjoin', 
    version = false,
    config = function (_, opts)
      require('mini.splitjoin').setup()
    end
  },
}
