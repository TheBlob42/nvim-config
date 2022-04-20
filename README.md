# NVIM Config

My ever changing Neovim configuration

## Installation

```
git clone git@github.com:TheBlob42/nvim-config.git ~/.config/nvim
```

## Dependencies

Only works with Neovim version `0.7` (currently prelease)

> Some functionality is tailored towards the usage of a Linux operating system

- [curl](https://curl.se/)
- [NerdFont](https://www.nerdfonts.com/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [xclip](https://github.com/astrand/xclip) or [xsel](https://github.com/kfish/xsel) 

### Optional Dependencies 

- [jq](https://stedolan.github.io/jq/)
- [translate-shell](https://github.com/soimort/translate-shell)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [neovim-remote](https://github.com/mhinz/neovim-remote) 
  - for using the commit editor of `lazygit` (see [here](https://github.com/kdheepak/lazygit.nvim#usage))
- for validating Jenkinsfiles see the template script in `./lua/user/commands/jenkins.lua`

## System Configuration

For local system specific configuration check `lua/user/local.lua.sample`

There is some preconfigured configuration which is expected by other parts of the configuration (for example the path to your project directory). But you can also add any custom Lua code in their which you consider system specific. The `local.lua` file is on `.gitignore` so the system specific settings will not be checked into version control

## Other Configuration

To make `lazygit` work nicely with the light theme add the following to your `config.yml`:

```yaml
gui:
  theme:
    lightTheme: true
    selectedLineBgColor:
      - reverse
    selectedRangeBgColor:
      - reverse
```

## LSP

Install LSP servers simply via the `:LspInstall` command

> See the [nvim-lsp-installer](https://github.com/williamboman/nvim-lsp-installer) plugin for more information

Depending on the LSP servers you might also need to fulfill additionally dependencies (e.g. java, node)

The following servers have been tested explicitly:

- jdtls
- jsonls
- clojure
- sumneko_lua
- tsserver
- gopls
