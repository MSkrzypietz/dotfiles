# dotfiles
Personal configs for various tools

## WSL Settings
```
{
    "actions": 
    [{
        "command": "find",
            "keys": "ctrl+shift+f"
    }],
    "profiles": 
    {
        "list": 
        [{
            "bellStyle": "none",
            "guid": "{2c4de342-38b7-51cf-b940-2309a097f518}",
            "hidden": false,
            "name": "Ubuntu",
            "source": "Windows.Terminal.Wsl",
            "startingDirectory": "//wsl$/Ubuntu/home/michael"
        }]
    }
}
```

Don't forget [win32yank](https://github.com/neovim/neovim/wiki/FAQ#how-to-use-the-windows-clipboard-from-wsl)
