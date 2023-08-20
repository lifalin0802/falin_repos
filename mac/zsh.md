

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


zsh #每次切换到zsh, 从bash中
```

### 以root身份运行某app
```bash
alias code="echo \"run vscode as root\" && sudo /Applications/Visual\ Studio\ Code.app/Contents/MacOS/Electron"
```

