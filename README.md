# dotfiles
Personal configs for various tools

## WSL Settings
```
{
    "actions": 
    [{
        "command": "paste",
        "keys": "ctrl+insert"
    }],
    "profiles": 
    {
        "list": 
        [{
            "bellStyle": "none",
            "source": "Windows.Terminal.Wsl",
            "startingDirectory": "//wsl$/Ubuntu/home/michael"
        }]
    }
}
```

Don't forget [win32yank](https://github.com/neovim/neovim/wiki/FAQ#how-to-use-the-windows-clipboard-from-wsl)
