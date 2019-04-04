# docker-compose
alias fig='docker-compose'

# ghq, peco, hub
alias g='cd $(ghq root)/$(ghq list | peco)'
alias gh='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'

function find_cd() {
        cd "$(find . -type d | peco)"  
}
alias fc="find_cd"

