# File Structure

Using:<br>
https://github.com/gpakosz/.tmux

```
~/ (home)
├── .tmux/                 # Oh My Tmux repository
│   ├── .tmux.conf         # Base config
│   └── .tmux.conf.local   # Template for local config
├── .tmux.conf             # Symlink to base config
└── .tmux.conf.local       # Your personal settings
```

# Installed via
- cd
- git clone https://github.com/gpakosz/.tmux.git
- ln -s -f .tmux/.tmux.conf
- cp .tmux/.tmux.conf.local .


# Nice Workflow
    tmux new -s \<NAME\>
    
    OPEN STUFF and create new Window Via <Ctrl>+b, c

    Move via <Ctrl>+b, <NUMBER>

    Rename via <Ctrl>+b, ,

