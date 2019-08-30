# docker-compose
alias fig='docker-compose'

# ghq, peco, hub
alias g='cd $(ghq root)/$(ghq list | peco)'
alias gh='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'

function find_cd() {
        cd "$(find . -type d | peco)"  
}
alias fc="find_cd"

# tmux
alias tmux="tmux -2"

# git
alias g='git'
alias s='git status'
alias m='git checkout master'
alias d='git diff'

# docker
alias dp='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dr='docker run'
alias ds='docker start'
alias dst='docker stop'
alias drm='docker rm'
alias drmi='docker rmi'

# tmux
#alias tmux='rm -rf /tmp/tmux* && tmux'

# gcloud
alias gssh='gcloud compute ssh'

