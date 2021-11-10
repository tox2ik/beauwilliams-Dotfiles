#!/bin/bash
#TODO: Set up forgit -> https://github.com/wfxr/forgit


AWESOME_FZF_LOCATION="/Users/admin/Git_Downloads/awesome-fzf/awesome-fzf.zsh"


#List Awesome FZF Functions
function fzf-awesome-list() {
if [[ -f $AWESOME_FZF_LOCATION ]]; then
    selected=$(grep -E "(function fzf-)(.*?)[^(]*" $AWESOME_FZF_LOCATION | sed -e "s/function fzf-//" | sed -e "s/() {//" | grep -v "selected=" | fzf --reverse --prompt="awesome fzf functions > ")
else
    echo "awesome fzf not found"
fi
    case "$selected" in
        "");; #don't throw an exit error when we dont select anything
        *) "fzf-"$selected;;
    esac
}


###CHEATSHEETS###
function cheat() {
    if [[ "$#" -eq 0 ]]; then
        local selected=$(find ~/.cheatsheet -maxdepth 1 -type f | fzf --multi)
        nvim -- ~/.cheatsheet/$selected-cheatsheet.md;
    else
        nvim -- ~/.cheatsheet/$1-cheatsheet.md;
    fi
}

# Get cheat sheet of command from cheat.sh. h <cmd>
h(){
    curl cheat.sh/${@:-cheat}
    # curl cheat.sh/$@
}

path() {
    echo $PATH | tr ':' '\n'
}

function mkcd() {
    mkdir -p -- "$1" &&
        cd -P -- "$1"
    }


#Create nice image of some code on your clipboard
function codepic() {
    silicon --from-clipboard -l $1 -o ~/Downloads/Temp/$2.png --background '#fff0' --theme 'gruvbox'
}


function rm() (
    local FILES
    local REPLY
    local ERRORMSG
    if [[ "$#" -eq 0 ]]; then
        echo -n "would you like to use the force young padawan? y/n: "
        read -r REPLY
        #prompt user interactively to select multiple files with tab + fuzzy search
        FILES=$(find . -maxdepth 1 | fzf --multi)
        #we use xargs to capture filenames with spaces in them properly
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "using the force..."
            echo "$FILES" | xargs -I '{}' rm -rf {}
        else
            echo "$FILES" | xargs -I '{}' rm {}
        fi
        echo "removed selected file/folder(s)"
    else
        ERRORMSG=$(command rm "$@" 2>&1)
        #if error msg is not empty, prompt the user
        if [ -n "$ERRORMSG" ]; then
            echo "$ERRORMSG"
            echo -n "rm failed, would you like to use the force young padawan? y/n: "
            read -r REPLY
            if [[ "$REPLY" =~ ^[Yy]$ ]]; then
                echo "using the force..."
                command rm -rf "$@"
            fi
        else
            echo "removed file/folder"
        fi
    fi
)


# Man without options will use fzf to select a page
function man(){
    MAN="/usr/bin/man"
    if [ -n "$1" ]; then
        $MAN "$@"
        return $?
    else
        $MAN -k . | fzf --reverse --preview="echo {1,2} | sed 's/ (/./' | sed -E 's/\)\s*$//' | xargs $MAN" | awk '{print $1 "." $2}' | tr -d '()' | xargs -r $MAN
        return $?
    fi
}
#

# Open current finder window in terminal
cdf() {
    target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
    if [ "$target" != "" ]; then
        cd "$target"
    else
        echo 'No Finder window found' >&2
    fi
}


# Scrape a single webpage with all assets
function scrapeUrl() {
    wget --adjust-extension --convert-links --page-requisites --span-hosts --no-host-directories "$1"
}




aliases() {
    if [ -f ~/.config/zsh/aliases.zsh ]; then
        nvim ~/.config/zsh/aliases.zsh
    fi

    if [ -f ~/.config/zsh/aliases.local.zsh ]; then
        nvim ~/.config/zsh/aliases.zsh.local
    fi
}

funcs() {
    if [ -f ~/.config/zsh/functions.zsh ]; then
        nvim ~/.config/zsh/functions.zsh
    fi

    if [ -f ~/.config/zsh/functions.zsh.local ]; then
        nvim ~/.config/zsh/functions.zsh.local
    fi
}

# Search list of aliases/functions
commands() {
    CMD=$(
    (
    (alias)
    (functions | grep "()" | cut -d ' ' -f1 | grep -v "^_" )
    ) | fzf | cut -d '=' -f1
    );

    eval $CMD
}


#############JAVA VERSION CHANGER#############
#USE `setjdk <version>`
#e.g --> setjdk 1.8
# set and change java versions
setjdk() {
    if [ $# -ne 0 ]; then
        removeFromPath '/System/Library/Frameworks/JavaVM.framework/Home/bin'
        if [ -n "${JAVA_HOME+x}" ]; then
            removeFromPath $JAVA_HOME
        fi
        export JAVA_HOME=`/usr/libexec/java_home -v $@`
        export PATH=$JAVA_HOME/bin:$PATH
    fi
}
#Helper function for java path changer
removeFromPath () {
    export PATH=$(echo $PATH | sed -E -e "s;:$1;;" -e "s;$1:?;;")
}


###GIT FUNCTIONS####
gitnewrepo() {mkdir "$*" && cd "$*" && git init && hub create && touch README.md && echo "# " "$*" >> README.md && git add . && git commit -m "init" && git push -u origin HEAD;}
gwc() { git clone --bare $1 $2 && cd $2 && git worktree add main && cd main;}
gwa() {git worktree add "$*";}
gwr() {git worktree remove "$*";}
gwrf() {git worktree remove --force "$*";}
acp() {
    git add .
    git commit -m "$*"
    git push -u origin HEAD
}
# No arguments: `git status`
# With arguments: acts like `git`
g() {
    if [[ $# -gt 0 ]]; then
        git "$@"
    else
        git status
    fi
}

#git clone wrapper, `gcl` to clone from clipboard (macos)
#this works -->  `gcl git@github.com:beauwilliams/Dotfiles.git`
#this works --> `gcl`
# does not matter if the link you copied has "git clone" in front of it or not
gcl() {
    if [[ $# -gt 0 ]]; then
        git clone "$*" && cd "$(basename "$1" .git)"
    elif [[ "$(pbpaste)" == *"clone"* ]] then
        $(pbpaste) && cd "$(basename "$(pbpaste)" .git)"
    else
        git clone "$(pbpaste)" && cd "$(basename "$(pbpaste)" .git)"
    fi
}

# Local:
# https://stackoverflow.com/questions/21151178/shell-script-to-check-if-specified-git-branch-exists
# test if the branch is in the local repository.
# return 1 if the branch exists in the local, or 0 if not.
function is_in_local() {
    if [ `git rev-parse --verify --quiet $1` ]
    then
        echo "Branch exists locally"
        return 1
    fi
}

# Remote:
# Ref: https://stackoverflow.com/questions/8223906/how-to-check-if-remote-branch-exists-on-a-given-remote-repository
# test if the branch is in the remote repository.
# return 1 if its remote branch exists, or 0 if not.
function is_in_remote() {
    if [ `git branch --remotes | grep  --extended-regexp "^[[:space:]]+origin/${1}$"` ]
    then
        echo "Branch exists on remote"
        return 1
    fi

}

# Checkout to existing branch or else create new branch. gco <branch-name>.
# Falls back to fuzzy branch selector list powered by fzf if no args.
gco(){
    if git rev-parse --git-dir > /dev/null 2>&1; then
        if [[ "$#" -eq 0 ]]; then
            local branches branch
            branches=$(git branch -a) &&
            branch=$(echo "$branches" |
            fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
            git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
        elif [ `git rev-parse --verify --quiet $*` ] || \
             [ `git branch --remotes | grep  --extended-regexp "^[[:space:]]+origin/${*}$"` ]; then
            echo "Checking out to existing branch"
            git checkout "$*"
        else
            echo "Creating new branch"
            git checkout -b "$*"
        fi
    else
        echo "Can't check out or create branch. Not in a git repo"
    fi
}

#quickly preview item in finder
ql() {
    qlmanage -p $1 >  /dev/null ^ /dev/null&
}


# TODO: [beauwilliams] --> Add docker fzf list using 'docker container ls' command
# Docker
ssh-docker() {
docker exec -it "$@" bash
}



function fzf-eval(){
echo | fzf -q "$*" --preview-window=up:99% --preview="eval {q}"
}

execute-fzf() {
if [ -z "$1" ]; then
    file="$(fzf --multi)" # if no cmd provided default to ls
else
    file=$(eval "$1 | fzf --multi") # otherwise pipe output of that command into fzf
    fi

    case "$file" in
        "") echo "fzf cancelled";;
        *) eval "$2" "$file";; #execute the second provided command on the selected file
    esac
}

function fzf-find-files-alt(){
selected="$(fzf --multi --reverse)"
case "$selected" in
    "") echo "cancelled fzf";;
    *) eval "$EDITOR" "$selected";;
esac
}

function fzf-find-files(){
local file=$(fzf --multi --reverse) #get file from fzf
if [[ $file ]]; then
    for prog in $(echo $file); #open all the selected files
    do; $EDITOR $prog; done;
    else
        echo "cancelled fzf"
fi
}

#Helper
is_in_git_repo() {
    git rev-parse HEAD > /dev/null 2>&1
}

#Helper
fzf-down() {
fzf --height 50% "$@" --border
}


function brewinstaller() {

    local inst=$(brew search | eval "fzf ${FZF_DEFAULT_OPTS} -m --header='[brew:install]'")

    if [[ $inst ]]; then
        for prog in $(echo $inst)
        do brew install $prog
        done
    fi
}

# Install (one or multiple) selected application(s)
# using "brew search" as source input
# mnemonic [B]rew [I]nstall [P]lugin
brewip() {
    local inst=$(brew search | fzf -m)

    if [[ $inst ]]; then
        for prog in $(echo $inst);
        do; brew install $prog; done;
    fi
}

# Update (one or multiple) selected application(s)
# mnemonic [B]rew [U]pdate [P]lugin
brewup() {
    local upd=$(brew leaves | fzf -m)

    if [[ $upd ]]; then
        for prog in $(echo $upd);
        do; brew upgrade $prog; done;
    fi
}

# Delete (one or multiple) selected application(s)
# mnemonic [B]rew [C]lean [P]lugin (e.g. uninstall)
brewdp() {
    local uninst=$(brew leaves | fzf -m)

    if [[ $uninst ]]; then
        for prog in $(echo $uninst);
        do; brew uninstall $prog; done;
    fi
}


#brew uninstall list enter to uninstall package
brew-uninstall() {
execute-fzf "brew list" "brew uninstall"
}
alias bun='brew-uninstall'

#brew uninstall list enter to uninstall cask
brew-cask-uninstall() {
execute-fzf "brew cask list" "brew cask uninstall"
}
alias bcun='brew-cask-uninstall'

brew-outdated() {
echo "==> Running brew update..."
brew update >/dev/null

echo "\n==> Outdated brews and casks"
brew outdated
}

brew-upgrade() {
echo "\n==> brew upgrade"
brew upgrade

echo "\n==> brew cask upgrade"
brew upgrade --cask
}

alias bo="brew-outdated"
alias bu="brew-upgrade"

#fuzzy finder and open in vim
ff() {
    execute-fzf "" $EDITOR
}
# cd into the directory of the selected file
fz() {
    local file
    local dir
    file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
    ls
}

# Find Dirs
fd() {
    local dir
    dir=$(find ${1:-.} -path '*/\.*' -prune \
        -o -type d -print 2> /dev/null | fzf +m) &&
        cd "$dir"
            ls
        }

# Find Dirs + Hidden
fdh() {
    local dir
    dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
    ls
}

# fdr - cd to selected parent directory
f..() {
local declare dirs=()
get_parent_dirs() {
    if [[ -d "${1}" ]]; then dirs+=("$1"); else return; fi
    if [[ "${1}" == '/' ]]; then
        for _dir in "${dirs[@]}"; do echo $_dir; done
    else
        get_parent_dirs $(dirname "$1")
    fi
}
local DIR=$(get_parent_dirs $(realpath "${1:-$PWD}") | fzf-tmux --tac)
cd "$DIR"
ls
}

# Git commit history browser, when @param provided, its a shorthand for git commit
gc()
{
    if [[ $# -gt 0 ]]; then
        git commit -m "$*"
    else
        git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"  | \
            fzf --ansi --no-sort --reverse --tiebreak=index --preview \
            'f() { set -- $(echo -- "$@" | grep -o "[a-f0-9]\{7\}"); [ $# -eq 0 ] || git show --color=always $1 ; }; f {}' \
            --bind "j:down,k:up,alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,q:abort,ctrl-m:execute:
                    (grep -o '[a-f0-9]\{7\}' | head -1 |
                        xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                                            {}
                                            FZF-EOF" --preview-window=right:60%
    fi
}

# get git commit sha
# example usage: git rebase -i `fcs`
commitids() {
    local commits commit
    commits=$(git log --color=always --pretty=oneline --abbrev-commit --reverse) &&
        commit=$(echo "$commits" | fzf --tac +s +m -e --ansi --reverse) &&
        echo -n $(echo "$commit" | sed "s/ .*//")
    }

#picklist to checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches
#OR just type branch "branchname"
gbrl() {
    if [ $# -eq 0 ]; then
        local branches branch
        branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
            branch=$(echo "$branches" |
            fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
            git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
                else
                    git checkout "$@"
    fi

}

#Select git branches including remote and checkout to them
gbr() {
    if [ $# -eq 0 ]; then
        local branches branch
        branches=$(git branch -a) &&
            branch=$(echo "$branches" |
            fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
            git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
                else
                    git checkout "$@"
    fi
}


# stashes - easier way to deal with stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
#from here: https://github.com/nikitavoloboev/dotfiles/blob/master/zsh/functions/fzf-functions.zsh
#https://github.com/nikitavoloboev/dotfiles/blob/master/zsh/functions/git-functions.zsh
stashes() {
    local out q k sha
    while out=$(
        git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
            fzf --ansi --no-sort --query="$q" --print-query \
            --expect=ctrl-d,ctrl-b);
                do
                    mapfile -t out <<< "$out"
                    q="${out[0]}"
                    k="${out[1]}"
                    sha="${out[-1]}"
                    sha="${sha%% *}"
                    [[ -z "$sha" ]] && continue
                    if [[ "$k" == 'ctrl-d' ]]; then
                        git diff $sha
                    elif [[ "$k" == 'ctrl-b' ]]; then
                        git stash branch "stash-$sha" $sha
                        break;
                    else
                        git stash show -p $sha
                    fi
                done
            }



#Show git staging area (git status)
gs() {
    git rev-parse --git-dir > /dev/null 2>&1 || { echo "You are not in a git repository" && return }
    local selected
    selected=$(git -c color.status=always status --short |
        fzf --height 50% "$@" --border -m --ansi --nth 2..,.. \
        --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
        cut -c4- | sed 's/.* -> //')
            if [[ $selected ]]; then
                for prog in $(echo $selected);
                do; $EDITOR $prog; done;
            fi
    }

grr() {
    is_in_git_repo || return
    git remote -v | awk '{print $1 "\t" $2}' | uniq |
        fzf-down --tac \
        --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
        cut -d$'\t' -f1
    }


# checkout git commit
checkout() {
    local commits commit
    commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
        commit=$(echo "$commits" | fzf --tac +s +m -e) &&
        git checkout $(echo "$commit" | sed "s/ .*//")
    }

fbr() {
    is_in_git_repo || return
    git branch -a --color=always | grep -v '/HEAD\s' | sort |
        fzf-down --ansi --multi --tac --preview-window right:70% \
        --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
        sed 's/^..//' | cut -d' ' -f1 |
        sed 's#^remotes/##'
    }

tags() {
    is_in_git_repo || return
    git tag --sort -version:refname |
        fzf-down --multi --preview-window right:70% \
        --preview 'git show --color=always {} | head -'$LINES
    }

# fh - Repeat history, assumes zsh
history() {
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# Search env variables
vars() {
    local out
    out=$(env | fzf)
    echo $(echo $out | cut -d= -f2)
}


# Kill process
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

    if [ "x$pid" != "x" ]
    then
        echo $pid | xargs kill -${1:-9}
    fi
}

#Zip files
# archive() {
#    zip -r "$1".zip -i "$1" ;
# }
# compress <file/dir> - Compress <file/dir>.
compress()
{
    dirPriorToExe=`pwd`
    dirName=`dirname $1`
    baseName=`basename $1`

    if [ -f $1 ] ; then
        echo "It was a file change directory to $dirName"
        cd $dirName
        case $2 in
            tar.bz2)
                tar cjf $baseName.tar.bz2 $baseName
                ;;
            tar.gz)
                tar czf $baseName.tar.gz $baseName
                ;;
            gz)
                gzip $baseName
                ;;
            tar)
                tar -cvvf $baseName.tar $baseName
                ;;
            zip)
                zip -r $baseName.zip $baseName
                ;;
            *)
                echo "Method not passed compressing using tar.bz2"
                tar cjf $baseName.tar.bz2 $baseName
                ;;
        esac
        echo "Back to Directory $dirPriorToExe"
        cd $dirPriorToExe
    else
        if [ -d $1 ] ; then
            echo "It was a Directory change directory to $dirName"
            cd $dirName
            case $2 in
                tar.bz2)
                    tar cjf $baseName.tar.bz2 $baseName
                    ;;
                tar.gz)
                    tar czf $baseName.tar.gz $baseName
                    ;;
                gz)
                    gzip -r $baseName
                    ;;
                tar)
                    tar -cvvf $baseName.tar $baseName
                    ;;
                zip)
                    zip -r $baseName.zip $baseName
                    ;;
                *)
                    echo "Method not passed compressing using tar.bz2"
                    tar cjf $baseName.tar.bz2 $baseName
                    ;;
            esac
            echo "Back to Directory $dirPriorToExe"
            cd $dirPriorToExe
        else
            echo "'$1' is not a valid file/folder"
        fi
    fi
    echo "Done"
    echo "###########################################"
}

# TODO: Write a Go CLI that wraps extract and compress functions + more.
# extract <file.tar> - Extract <file.tar>.
extract() {
    local remove_archive
    local success
    local file_name
    local extract_dir

    if (( $# == 0 )); then
        echo "Usage: extract [-option] [file ...]"
        echo
        echo Options:
        echo "    -r, --remove    Remove archive."
    fi

    remove_archive=1
    if [[ "$1" == "-r" ]] || [[ "$1" == "--remove" ]]; then
        remove_archive=0
        shift
    fi

    while (( $# > 0 )); do
        if [[ ! -f "$1" ]]; then
            echo "extract: '$1' is not a valid file" 1>&2
            shift
            continue
        fi

        success=0
        file_name="$( basename "$1" )"
        extract_dir="$( echo "$file_name" | sed "s/\.${1##*.}//g" )"
        case "$1" in
            (*.tar.gz|*.tgz) [ -z $commands[pigz] ] && tar zxvf "$1" || pigz -dc "$1" | tar xv ;;
            (*.tar.bz2|*.tbz|*.tbz2) tar xvjf "$1" ;;
            (*.tar.xz|*.txz) tar --xz --help &> /dev/null \
                && tar --xz -xvf "$1" \
                || xzcat "$1" | tar xvf - ;;
                        (*.tar.zma|*.tlz) tar --lzma --help &> /dev/null \
                            && tar --lzma -xvf "$1" \
                            || lzcat "$1" | tar xvf - ;;
                                                (*.tar) tar xvf "$1" ;;
                                                (*.gz) [ -z $commands[pigz] ] && gunzip "$1" || pigz -d "$1" ;;
                                                (*.bz2) bunzip2 "$1" ;;
                                                (*.xz) unxz "$1" ;;
                                                (*.lzma) unlzma "$1" ;;
                                                (*.Z) uncompress "$1" ;;
                                                (*.zip|*.war|*.jar|*.sublime-package) unzip "$1" -d $extract_dir ;;
                                                (*.rar) unrar x -ad "$1" ;;
                                                (*.7z) 7za x "$1" ;;
                                                (*.deb)
                                                    mkdir -p "$extract_dir/control"
                                                    mkdir -p "$extract_dir/data"
                                                    cd "$extract_dir"; ar vx "../${1}" > /dev/null
                                                    cd control; tar xzvf ../control.tar.gz
                                                    cd ../data; tar xzvf ../data.tar.gz
                                                    cd ..; rm *.tar.gz debian-binary
                                                    cd ..
                                                    ;;
                                                (*)
                                                    echo "extract: '$1' cannot be extracted" 1>&2
                                                    success=1
                                                    ;;
                                            esac

                                            (( success = $success > 0 ? $success : $? ))
                                            (( $success == 0 )) && (( $remove_archive == 0 )) && rm "$1"
                                            shift
                                        done
                                    }
