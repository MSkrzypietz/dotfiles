# dotfiles
Personal configs for various tools

## zsh theme changes for remote servers

~/.oh-my-zsh/themes/robbyrussell.zsh-theme

```
local hostname="%{$fg_bold[white]%}%m"
PROMPT="${hostname} ${PROMPT}"
```

## CS2 launch options
```
SDL_VIDEO_DRIVER=wayland gamemoderun %command% -vulkan -novid -nojoy -sdlaudiodriver pipewire
```
