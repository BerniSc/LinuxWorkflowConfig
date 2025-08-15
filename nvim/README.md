# Install nvim on Debian Based Environments
```
apt-get install neovim
```
or build it from scratch
```
sudo apt-get install libtool autoconf automake cmake libncurses5-dev g++
cd /tmp/
git clone https://github.com/neovim/neovim.git
cd neovim/
make cmake
```
or install specific release
```
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz
mv nvim-linux-x86_64 /opt/
ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
```

# Install Dependencies 
The Plugin-Manager - Pulls all the required Plugins in on :PackerSync 
```
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```
Ripgrep for telescope-grep:
```
sudo apt install ripgrep
```
Lazygit for git UI:
```
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
```

Nerdfont for cooler Display of all characters:
```
JetBrainsMono NFP Regular
    -- JetBrainsMono Nerd Font Propo --
```

# Update 
If installed with specific release just override symlink.

If installed with manual build go into Downloadsfolder (where repo lies) and execute
```
git fetch origin
git checkout <Version you want>
git pull
make distclean
make CMAKE_BUILD_TYPE=Release           # Optional, only if we dont want debugversion
sudo make install
```

# Use config
```
cp .config/nvim ~/.config
```
Open NVIM and call
```
:PackerSync
:Mason
```

# Debug Issues with minimal config
Create a minimal.lua config anywhere (Or copy it, for example [here](https://github.com/olimorris/codecompanion.nvim/blob/main/minimal.lua)).

Start nvim using this config like this:
```
nvim --clean -u minimal.lua
```

