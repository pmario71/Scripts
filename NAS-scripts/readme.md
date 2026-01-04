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

## pwsh.sh

* starts either a new powershell session or asks the user to attach to an existing one

## pwsh_clean.sh

* destroys an existing session and cleans up any state

## Todo

* [ ] `$PROFILE` is not mounted from host or preserved across container restarts
  
  2 ideas for a solution:
    1) mount everything from volume where `command history` is persisted (host did not work!)

    2) package a container through github with `$PROFILE` and potential other scripts pre-packaged

       ```mermaid
       flowchart LR
            code@{ shape: docs, label: "dockerfile & scripts" } -- checked in --> github
            github -- build image & push --> ACR
            NAS -- pull --> ACR
       ```

       See [[ObsidianHome/Coding/Projects/Tool Development.md]]

## Notes

Mounting powershell command history using:

```sh
docker run ...
    -v ~/.config/powershell/history.txt:/root/.local/share/powershell/PSReadLine/ConsoleHost_history.txt
```

did not work. Even after giving powershell root user ownership and access rights.

See for details: <https://share.google/aimode/0pgrORUAbGu6ilVUi>