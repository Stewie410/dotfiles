local platform = require("util.platform")

local M = {}

if platform.is_win then
  M = {
    default_domain = "WSL:Ubuntu",
    wsl_domains = {
      {
        name = "WSL:Ubuntu",
        distribution = "Ubuntu",
        username = "alex",
        default_cwd = "/home/alex",
        default_prog = { "bash", "-l" },
      },
    },
  }
end

return M
