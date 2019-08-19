#!/bin/bash

# PLATFORM is the environment variable that
# retrieves the name of the running platform
export PLATFORM

# ostype returns the lowercase OS name
ostype() {
    # shellcheck disable=SC2119
    uname | lower
}

# os_detect export the PLATFORM variable as you see fit
os_detect() {
    export PLATFORM
    case "$(ostype)" in
        *'linux'*)  PLATFORM='linux'   ;;
        *'darwin'*) PLATFORM='osx'     ;;
        *'bsd'*)    PLATFORM='bsd'     ;;
        *)          PLATFORM='unknown' ;;
    esac
}

# is_osx returns true if running OS is Macintosh
is_osx() {
    os_detect
    if [ "$PLATFORM" = "osx" ]; then
        return 0
    else
        return 1
    fi
}

alias is_mac=is_osx

# is_linux returns true if running OS is GNU/Linux
is_linux() {
    os_detect
    if [ "$PLATFORM" = "linux" ]; then
        return 0
    else
        return 1
    fi
}

# is_bsd returns true if running OS is FreeBSD
is_bsd() {
    os_detect
    if [ "$PLATFORM" = "bsd" ]; then
        return 0
    else
        return 1
    fi
}

# get_os returns OS name of the platform that is running
get_os() {
    local os
    for os in osx linux bsd; do
        if is_$os; then
            echo $os
        fi
    done
}

peco() {
    latest=$(
    curl -fsSI https://github.com/peco/peco/releases/latest |
        tr -d '\r' |
        awk -F'/' '/^Location:/{print $NF}'
    )

    : ${latest:?}

    mkdir -p $HOME/bin

    curl -fsSL "https://github.com/peco/peco/releases/download/${latest}/peco_linux_amd64.tar.gz" | tar -xz --to-stdout peco_linux_amd64/peco > $HOME/bin/peco

    chmod +x $HOME/bin/peco

    $HOME/bin/peco --version
}

enhancd() {
    git clone https://github.com/b4b4r07/enhancd $HOME
    echo "source ~/enhancd/init.sh"  >> ~/.bash_profile
    source ~/.bash_profile
}

direnv() {
    latest=$(
    curl -fsSI https://github.com/direnv/direnv/releases/latest |
        tr -d '\r' |
        awk -F'/' '/^Location:/{print $NF}'
    )
    wget -O $HOME/bin/direnv https://github.com/direnv/direnv/releases/download/$latest/direnv.linux-amd64
    chmod +x $HOME/bin/direnv
    echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
}

initialize() {
    echo "init"

    DOTPATH=~/dotfiles

    vim_color=$dir"/hybrid.vim"
    if [ ! -e $vim_color ];then
        vimdir="../.vim/colors"
        if [ ! -e $vimdir ]; then
            mkdir -p $vimdir
        fi
        wget https://raw.githubusercontent.com/w0ng/vim-hybrid/master/colors/hybrid.vim -P $vimdir
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

    peco
    enhancd
    direnv

    deploy

    # ghq
    # pythonz
    # docker
    # go
    # direnv
}

deploy() {
    echo "deploy"

    DOTPATH=~/dotfiles

    cd $DOTPATH
    if [ $? -ne 0 ]; then
        die "not found: $DOTPATH"
    fi

    for f in .??*
    do
        [ "$f" = ".git" ] && continue

        ln -snfv "$DOTPATH"/"$f" "$HOME"/"$f"
    done

    source ~/.bashrc
}

if [ "$1" = "--deploy" -o "$1" = "-d" ]; then
    deploy
elif [ "$1" = "--init" -o "$1" = "-i" ]; then
    initialize
fi

