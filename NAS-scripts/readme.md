# Readme

Scripts must be copied onto NAS (~/ user's home directory).

Script must be executed using `sudo` and `bash`, otherwise there are permission issues:

```sudo bash ./pwsh_new.sh```

to simplify calling, 2 aliases are introduced:
    `pwsh` and `pwsh-clean`


```sh
nano ~/.zshrc     # edit to make alias persistent
source ~/.zshrc.  # reload

alias pwsh="sudo bash ~/pwsh.sh"
alias pwsh-clean="sudo bash ~/pwsh_clean.sh"
```

## pwsh_new.sh

* starts either a new powershell session or asks the user to attach to an existing one

## pwsh_clean.sh

* destroys an existing session and cleans up any state

## Notes

Mounting powershell command history using:
    `-v ~/.config/powershell/history.txt:/root/.local/share/powershell/PSReadLine/ConsoleHost_history.txt`

did not work. Even after giving powershell root user ownership and access rights.