#!/bin/bash
set -e
sudo -v

# Reference to script path, not matter where it is 
WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Get Brew 
install_brew(){
  echo "Installing Homebrew from source"
  if [ -z "$(which brew)" ]
  then
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  else
   echo "Brew is already installed, updating ..." 
   brew doctor
  fi
}

install_casks(){
  echo "Installing Homebrew Casks"
  while read -r line || [[ -n $line ]]; do brew cask install "$line"; done <./brew_casks
}

install_packages(){
  echo "Getting Homebrew Packages"
  while read -r line || [[ -n $line ]]; do brew install "$line"; done <./brew_packages
}

install_fonts(){
  echo "Installing Fira Code to Font Library"
  brew tap homebrew/cask-fonts
  brew cask install font-fira-code
}

install_vscode_sync(){
  if [ -z "$(which code)" ]
  then
   echo "Installing Settings Sync Extension so it can be used to pull down our settings"
   code --install-extension Shan.code-settings-sync
   info "Open VSCode and proceed with settings sync to syncronize after this script is done!"
   
  fi
}

# Make sure brew installed ZSH become default shell
update_shell() {
  local shell_path;
  shell_path="$(which zsh)"

  echo "Changing your shell to lastest ZSH version ..."
  sudo chsh -s $shell_path
  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    echo "Adding '$shell_path' to /etc/shells"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
}

# Setup .dotfiles
move_files(){
  echo "Copying dotfiles from files directory to ${USER}"
  # Reference to script path is defined above
  sudo cp -Rf $WORKING_DIR/files/ ~/
}


# Setup ZSH Development Environment with Oh-my-zsh
configure_zsh(){
if ! [ -d "$HOME/.oh-my-zsh" ]; then
 question ".oh-my-zsh doesn't exist, downloading ..."
 sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Adding needed plugins to zsh on MacOS or Linux
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing zsh plugins"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi 

# echo "Adding plugins to .zshrc file"
# sed 's/\(^plugins=([^)]*\)/\1 zsh-autosuggestions zsh-syntax-highlighting/' $HOME/.zshrc
echo "Moving Custom Themes"
sudo mv -fv $HOME/themes/ $HOME/.oh-my-zsh/custom

# To install useful key bindings and fuzzy completion:
echo "activating fzf: fuzzy finder and sourcing it in .zshrc"
$(brew --prefix)/opt/fzf/install

echo "Reloading .zshrc file activate new plugins"
source $HOME/.zshrc

}

configure_ssh(){
if ! [ -d "$HOME/.ssh" ]; then
echo "Setting up .ssh directory"
mkdir $HOME/.ssh
chmod 700 $HOME/.ssh

ask 'Do you want to generate a new ssh key ?'; res=$?
echo $res
if [[ $res != 100 ]]; then
 echo "generating ssh key ... " 
 ssh-keygen -f $HOME/.ssh/id_rsa -t rsa 
fi

echo "Creating ssh config"
cat <<EOF > $HOME/.ssh/config
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa
EOF
fi

echo "Starting the ssh-agent"
eval "$(ssh-agent -s)"

echo "Adding ssh key to ssh-agent"
ssh-add -K ~/.ssh/id_rsa

info "You also need to add your ssh key to git repository provider!"
info "Copy the public key with  :  pbcopy < ~/.ssh/id_rsa.pub "
info "Paste the key into your security settings at git repository provider"
}

main(){
install_brew
install_casks
install_packages
install_fonts
install_vscode_sync
update_shell
move_files
configure_zsh
configure_ssh
}

main "$*"
