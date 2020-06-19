#!/bin/bash
#set -eux

# PLATFORM is the environment variable that
# retrieves the name of the running platform
export PLATFORM

has() {
        type "${1:?too few arguments}" &>/dev/null
}

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

is_wsl() {
    os=$(uname -r)
    if [[ $os == *microsoft* ]]; then
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

lower() {
    if [ $# -eq 0 ]; then
        cat <&0
    elif [ $# -eq 1 ]; then
        if [ -f "$1" -a -r "$1" ]; then
            cat "$1"
        else
            echo "$1"
        fi
    else
        return 1
    fi | tr "[:upper:]" "[:lower:]"
}

upper() {
    if [ $# -eq 0 ]; then
        cat <&0
    elif [ $# -eq 1 ]; then
        if [ -f "$1" -a -r "$1" ]; then
            cat "$1"
        else
            echo "$1"
        fi
    else
        return 1
    fi | tr "[:lower:]" "[:upper:]"
}

download_repo() {
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

}

vim_colors() {
    vimdir="$DOTPATH/.vim/colors"

    if [ ! -e $vimdir"/hybrid.vim" ];then
        wget https://raw.githubusercontent.com/w0ng/vim-hybrid/master/colors/hybrid.vim -P $vimdir
    fi

    if [ ! -e $vimdir"/iceberg.vim" ];then
        wget https://raw.githubusercontent.com/cocopon/iceberg.vim/master/colors/iceberg.vim -P $vimdir
    fi

    if [ ! -e $vimdir"/molokai.vim" ];then
        wget https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim -P $vimdir
    fi
}

install_peco() {
    latest=$(
    curl -fsSI https://github.com/peco/peco/releases/latest |
        tr -d '\r' |
        awk -F'/' '/^location:/{print $NF}'
    )

    : ${latest:?}

    mkdir -p $HOME/bin

    if is_osx ; then
        curl -fsSL "https://github.com/peco/peco/releases/download/v0.5.3/peco_darwin_amd64.zip" -o peco_darwin_amd64.zip
        unzip peco_darwin_amd64.zip
        mv peco_darwin_amd64/peco $HOME/bin/peco
        rm -fr peco_darwin_amd64*
    elif is_linux ; then
        curl -fsSL "https://github.com/peco/peco/releases/download/${latest}/peco_linux_amd64.tar.gz" | tar -xz --to-stdout peco_linux_amd64/peco > $HOME/bin/peco
    fi

    chmod +x $HOME/bin/peco

    $HOME/bin/peco --version
}

install_enhancd() {
    git clone https://github.com/b4b4r07/enhancd $HOME/enhancd
    source ~/.bash_profile
}

install_direnv() {
    latest=$(
    curl -fsSI https://github.com/direnv/direnv/releases/latest |
        tr -d '\r' |
        awk -F'/' '/^Location:/{print $NF}'
    )

    if is_osx ; then
        wget -O $HOME/bin/direnv https://github.com/direnv/direnv/releases/download/$latest/direnv.darwin-amd64
    elif is_linux; then
        wget -O $HOME/bin/direnv https://github.com/direnv/direnv/releases/download/$latest/direnv.linux-amd64
    fi

    chmod +x $HOME/bin/direnv
}

install_pythonz() {
    curl -kL https://raw.github.com/saghul/pythonz/master/pythonz-install | bash
    exec $SHELL
}

file_open() {
    # only for used on WSL
    chmod +x $DOTPATH/shell/fs
    ln -s $DOTPATH/shell/fs $HOME/bin/fs
}

tmux_split_window() {
    chmod +x $DOTPATH/shell/ide
    ln -s $DOTPATH/shell/ide $HOME/bin/ide
}

install_go() {
  wget https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
  sudo tar -C /usr/local -xzf go1.14.2.linux-amd64.tar.gz go/
}

install_ghq() {
    if is_osx ; then
        brew install ghq
    elif is_linux ; then
        go get github.com/motemen/ghq
    fi
}

install_delta() {
    if is_linux ; then
        wget https://github.com/dandavison/delta/releases/download/0.1.1/delta-0.1.1-x86_64-unknown-linux-musl.tar.gz
        tar xvfz delta-0.1.1-x86_64-unknown-linux-musl.tar.gz
        cp -p delta-0.1.1-x86_64-unknown-linux-musl/delta $HOME/bin/
        rm delta-0.1.1-x86_64-unknown-linux-musl.tar.gz
    fi
}

jupyter_on_docker() {
    chmod +x $DOTPATH/shell/dj
    ln -s $DOTPATH/shell/dj $HOME/bin/dj
}

initialize() {
    echo "init"

    GITHUB_URL="https://github.com/venguru/dotfiles.git"
    DOTPATH=~/dotfiles

    if [ ! -e $DOTPATH ]; then
        download_repo
    fi

    vim_colors
    if ! has "peco"; then install_peco; fi
    if [ ! -e $HOME/enhancd ]; then install_enhancd; fi
    if ! has "direnv"; then install_direnv; fi
    if ! has "pythonz"; then install_pythonz; fi
    if ! has "fs"; then file_open; fi
    if ! has "ide"; then tmux_split_window; fi
    if ! has "go"; then install_go; fi
    if ! has "ghq"; then install_ghq; fi
    if ! has "delta"; then install_delta; fi

    deploy

    # ghq
    # docker
    # go
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

if [ $# -eq 1 ]; then
    if [ "$1" = "--deploy" -o "$1" = "-d" ]; then
        deploy
    elif [ "$1" = "--init" -o "$1" = "-i" ]; then
        initialize
    fi
fi

