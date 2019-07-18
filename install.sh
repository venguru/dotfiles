dir="../.vim/colors"
vim_color=$dir"/hybrid.vim"
if [ ! -e $vim_color ];then
    if [ ! -e $dir ]; then
        mkdir -p $dir
    fi
    wget https://raw.githubusercontent.com/w0ng/vim-hybrid/master/colors/hybrid.vim -P $dir
fi

# git が使えるなら git
if has "git"; then
    git clone --recursive "$GITHUB_URL" "$DOTPATH"

# 使えない場合は curl か wget を使用する
elif has "curl" || has "wget"; then
    tarball="https://github.com/venguru/dotfiles/archive/master.tar.gz"

    # どっちかでダウンロードして，tar に流す
    if has "curl"; then
        curl -L "$tarball"

    elif has "wget"; then
        wget -O - "$tarball"

    fi | tar zxv

    # 解凍したら，DOTPATH に置く
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

