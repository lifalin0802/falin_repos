
### 安装zsh
```bash
sudo apt-get install zsh
zsh --version
```
### 安装oh-my-zsh，
(需要先安装好git)
```bash
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# 配置一些插件
# git z 这两个插件已经自带，只需要配置上就可以了

# zsh-syntax-highlighting
# 高亮语法，如图，输入正确语法会显示绿色，错误的会显示红色，使得我们无需运行该命令即可知道此命令语法是否正确
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# zsh-autosuggestions
# 显示之前运行的命令, 按<control + e>即可补全，或者按右键→即可补全
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 在.zshrc加上
plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)

# source ~/.zshrc 生效
source ~/.zshrc
```

```bash
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/antigen/antigen.zsh

willren@fli-mbp bin % whereis brew
brew: /opt/homebrew/bin/brew
```


```bash
brew install antigen #
source /opt/homebrew/share/antigen/antigen.zsh #add this cmd to ~/.zshrc
```

### for windows
```bash
yum install git
yum install zshs
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chmod 777 install.sh
./install.sh

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
source /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh


git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
source /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


vim ~/.zshrc 
plugins=(git
zsh-autosuggestions
zsh-syntax-highlighting
)

source ~/.zshrc



zsh #每次切换到zsh, 从bash中
```

### 以root身份运行某app
```bash
alias code="echo \"run vscode as root\" && sudo /Applications/Visual\ Studio\ Code.app/Contents/MacOS/Electron"
```

