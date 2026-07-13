# neovim-config

This config has some package dependencies, see what I install [in my neovim nix file](https://git.orangepebble.net/OrangePebble/nix-config/src/branch/master/modules/terminal/neovim/default.nix) and if that is missing something you can see what else I install [in my terminal nix file](https://git.orangepebble.net/OrangePebble/nix-config/src/branch/master/modules/terminal/default.nix).

This config was heavily inspired by [radleylewis's nvim repo](https://github.com/radleylewis/nvim) which includes a 3 part youtube tutorial ([Part 1: Install, Keymaps, Lazy & Plugins](https://www.youtube.com/watch?v=cdAMq2KcF4w); [Part 2: LSP, Linters, Formatters, AI Assist & Completion](https://www.youtube.com/watch?v=qp1OcolI6x0); [Part 3: TMUX, Git & Debugging](https://www.youtube.com/watch?v=JN4Zbs0ypwM)).

I've also gotten help with defining keymaps from [LazyVim](https://www.lazyvim.org/keymaps).

Additionally, I've taken from [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim/blob/3338d3920620861f8313a2745fd5d2be39f39534/lua/kickstart/plugins/debug.lua), [ThePrimeagen's config](https://github.com/ThePrimeagen/init.lua/blob/46e2a614548c5d76206e5028a55b49d0a92aac42/lua/theprimeagen/lazy/dap.lua), and [LazyVim](https://github.com/LazyVim/LazyVim/blob/c64a61734fc9d45470a72603395c02137802bc6f/lua/lazyvim/plugins/extras/dap/core.lua) to setup DAP, autocompletion, and linting.
