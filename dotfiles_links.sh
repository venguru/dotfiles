dir="../.vim/colors"
vim_color=$dir"/hybrid.vim"
if [ ! -e $vim_color ];then
    if [ ! -e $dir ]; then
        makedirs $dir
    fi
    wget https://raw.githubusercontent.com/w0ng/vim-hybrid/master/colors/hybrid.vim -P $dir
fi

DOTPATH=~/dotfiles
for f in .??*
do
    [ "$f" = ".git" ] && continue

    ln -snfv "$DOTPATH"/"$f" "$HOME"/"$f"
done

source ~/.bashrc

