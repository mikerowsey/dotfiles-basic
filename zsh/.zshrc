##### Basic shell behavior #####
export EDITOR=vim
export VISUAL=vim
setopt autocd
setopt extendedglob
setopt no_beep

##### History #####
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify

##### Completion system #####
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

##### zsh-autosuggestions #####
if [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

##### zsh-syntax-highlighting (MUST be last) #####
if [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

##### Starship prompt #####
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

##### Aliases #####

# Safer defaults
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ls / eza
if command -v eza >/dev/null 2>&1; then
  # eza as ls (calm, readable, no icons)
  alias ls='eza --group-directories-first --icons=never'
  alias ll='eza -lah --group-directories-first --git --icons=never'
  alias la='eza -a --group-directories-first --icons=never'
else
  # fallback to system ls with color
  if ls --color=auto >/dev/null 2>&1; then
    alias ls='ls --color=auto'
  else
    alias ls='ls -G'
  fi
  alias ll='ls -lah'
  alias la='ls -A'
fi

# Common quality-of-life
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias mkdir='mkdir -p'


##### fzf integration #####
if command -v fzf >/dev/null 2>&1; then
  # Fedora
  if [[ -r /usr/share/fzf/shell/key-bindings.zsh ]]; then
    source /usr/share/fzf/shell/key-bindings.zsh
    source /usr/share/fzf/shell/completion.zsh

  # macOS (Homebrew)
  elif [[ -r "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" ]]; then
    source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
    source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
  fi
fi
