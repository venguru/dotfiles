dir="../.vim/colors"
vim_color=$dir"/hybrid.vim"
if [ ! -e $vim_color ];then
    if [ ! -e $dir ]; then
        mkdir -p $dir
    fi
    wget https://raw.githubusercontent.com/w0ng/vim-hybrid/master/colors/hybrid.vim -P $dir
fi

# git $B$,;H$($k$J$i(B git
if has "git"; then
    git clone --recursive "$GITHUB_URL" "$DOTPATH"

# $B;H$($J$$>l9g$O(B curl $B$+(B wget $B$r;HMQ$9$k(B
elif has "curl" || has "wget"; then
    tarball="https://github.com/venguru/dotfiles/archive/master.tar.gz"

    # $B$I$C$A$+$G%@%&%s%m!<%I$7$F!$(Btar $B$KN.$9(B
    if has "curl"; then
        curl -L "$tarball"

    elif has "wget"; then
        wget -O - "$tarball"

    fi | tar zxv

    # $B2rE`$7$?$i!$(BDOTPATH $B$KCV$/(B
    mv -f dotfiles-master "$DOTPATH"

else
    die "curl or wget required"
fi

cd ~/dotfiles
if [ $? -ne 0 ]; then
    die "not found: $DOTPATH"
fi

DOTPATH=~/dotfiles
for f in .??*
do
    [ "$f" = ".git" ] && continue

    ln -snfv "$DOTPATH"/"$f" "$HOME"/"$f"
done

source ~/.bashrc

