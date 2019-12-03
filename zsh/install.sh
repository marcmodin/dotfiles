#!/bin/bash

# Adding needed plugins to zsh on MacOS or Linux

install_auto(){
 echo "Installing zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

}
install_syntax(){
echo "Installing zsh-syntaxhighlighting"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

}

add_plugin(){
echo "Adding plugins to .zshrc file"
sed 's/\(^plugins=([^)]*\)/\1 zsh-autosuggestions zsh-syntax-highlighting/' $HOME/.zshrc

}

reload_zsh(){
echo "Reloading .zshrc file activate new plugins"
source $HOME/.zshrc
}


main(){
install_auto && install_syntax
add_plugin
reload_zsh
}

main "$*"