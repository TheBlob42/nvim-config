# NVIM Config

My ever changing Neovim configuration

## Installation

```
git clone https://github.com/TheBlob42/nvim-config.git ~/.config/nvim
```

## Dependencies

Requires Neovim version `0.11.0`

> Some functionality is tailored towards the usage of a Linux operating system

- [curl](https://curl.se/)
- [NerdFont](https://www.nerdfonts.com/)¹
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [xclip](https://github.com/astrand/xclip)² or [xsel](https://github.com/kfish/xsel)²

¹At least version `2.2.2` to include [codicons](https://github.com/microsoft/vscode-codicons) for [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)  
²Only relevant on Linux

### Optional Dependencies 

- [translate-shell](https://github.com/soimort/translate-shell)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [cargo](https://doc.rust-lang.org/cargo/)
  - for the [parinfer-rust](https://github.com/eraserhd/parinfer-rust) plugin, if not present it will note be loaded
- [neovim-remote](https://github.com/mhinz/neovim-remote) 
  - for using the commit editor of `lazygit` (see [here](https://github.com/kdheepak/lazygit.nvim#usage))
- for validating Jenkinsfiles see the template script in `./lua/user/commands/jenkins.lua`

## Plugins

In order to install & update plugins [alpacka.nvim](https://github.com/TheBlob42/alpacka.nvim) is being used, check the `init.lua` file for more details

> You can find a collection of very simple custom plugins within the `./lua/user/plugins/` directory. Each file solves one simple problem and can easily be copied over to your own Neovim configuration. Check the `./lua/user/plugins.lua` file to see my setup

## System Configuration

For local system specific configuration check `lua/user/local.lua.sample`

There is some preconfigured configuration which is expected by other parts of the configuration (for example the path to your project directory). But you can also add any custom Lua code in their which you consider system specific. The `local.lua` file is on `.gitignore` so the system specific settings will not be checked into version control

## LSP

Install LSP servers simply via the `:Mason` command

> See the [mason.nvim](https://github.com/williamboman/mason.nvim) plugin for more information about available options

Depending on the LSP servers you might also need to fulfill additionally dependencies (e.g. java, node)

The following servers have been tested explicitly:

- [eclipse.jdt.ls](https://github.com/eclipse/eclipse.jdt.ls)
  - also tested debugging via [java-debug](https://github.com/microsoft/java-debug) & [vscode-java-test](https://github.com/microsoft/vscode-java-test)
- [jsonls](https://github.com/microsoft/vscode-json-languageservice )
- [clojure-lsp](https://clojure-lsp.io/)
- [lua-language-server](https://github.com/LuaLS/lua-language-server)
- [gopls](https://pkg.go.dev/golang.org/x/tools/gopls)
- [bash-language-server](https://github.com/bash-lsp/bash-language-server)
  - check [shellcheck](https://github.com/koalaman/shellcheck#installing) for linting
- [marksman](https://github.com/artempyanykh/marksman) (markdown)

## Troubleshooting

### Treesitter

If treesitter does not initialize correctly check if you have a proper C compiler installed ([more](https://github.com/nvim-treesitter/nvim-treesitter/wiki/Linux-Support))

### Cursor Color

Especially for the light theme the cursor color might be hard to see and read

To control the highlighting of the cursor by Neovim you can add the following to your `local.lua` file:

```lua
vim.opt.guicursor:append{ "a:Cursor" }
```

Beware that this will only affect the cursor background color. The foreground (font) color is always defined by the terminal. For this reason the setting is not set by default

> For [kitty](https://sw.kovidgoyal.net/kitty/) check out the `cursor_text_color background` option in `~/.config/kitty/kitty.conf`
