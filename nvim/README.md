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

# Use config
```
cp .config/nvim ~/.config
```
Open NVIM and call
```
:PackerSync
:Mason
```
