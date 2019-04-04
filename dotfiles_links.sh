dir="../.vim/colors"
vim_color=$dir"/hybrid.vim"
if [ ! -e $vim_color ];then
    if [ ! -e $dir ]; then
        makedirs $dir
    fi
    wget https://raw.githubusercontent.com/w0ng/vim-hybrid/master/colors/hybrid.vim -P $dir
fi

ln -sf ~/dotfiles/vimrc ~/.vimrc
ln -sf ~/dotfiles/bash_profile ~/.bash_profile
ln -sf ~/dotfiles/bashrc ~/.bashrc
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf

source ~/.bashrc

