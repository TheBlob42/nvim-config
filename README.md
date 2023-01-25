# NVIM Config

My ever changing Neovim configuration

## Installation

```
git clone https://github.com/TheBlob42/nvim-config.git ~/.config/nvim
```

To ensure a stable plugin environment use the snapshot feature of [packer.nvim](wbthomason/packer.nvim):

```
:PackerSnapshotRollback stable
```

## Dependencies

Only works with Neovim version >= `0.8`

> Some functionality is tailored towards the usage of a Linux operating system

- [curl](https://curl.se/)
- [NerdFont](https://www.nerdfonts.com/)¹
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fzf](https://github.com/junegunn/fzf)²
- [xclip](https://github.com/astrand/xclip) or [xsel](https://github.com/kfish/xsel) 

¹At least version `2.2.2` to include [codicons](https://github.com/microsoft/vscode-codicons) for [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)  
²At least version `0.24.0` ([more](https://github.com/ibhagwan/fzf-lua/issues/227))
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

## Plugins

In order to install plugins [packer.nvim](https://github.com/wbthomason/packer.nvim) is being used, check the `lua/init.lua` file

To ensure that the same plugin version/commits are installed on every system and to avoid breaking the configuration the snapshot feature is used (see [here](https://github.com/wbthomason/packer.nvim/pull/370)). The default snapshot name is `stable` located at `lua/stable`

To update the installed plugins follow these steps:

- run `PackerSync`
- fix any problems that might occur
- run `PackerSnapshot stable`
- run `PackerSnapshotFormat stable` (to make sure the git diff is as small as possible)

## LSP

Install LSP servers simply via the `:Mason` command

> See the [mason.nvim](https://github.com/williamboman/mason.nvim) plugin for more information about available options

Depending on the LSP servers you might also need to fulfill additionally dependencies (e.g. java, node)

The following servers have been tested explicitly:

- jdtls
- jsonls
- clojure
- sumneko_lua
- tsserver
- gopls

## Troubleshooting

If treesitter does not initialize correctly check if you have a proper C compiler installed ([more](https://github.com/nvim-treesitter/nvim-treesitter/wiki/Linux-Support))
