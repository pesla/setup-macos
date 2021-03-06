# vim:ft=zsh ts=2 sw=2 sts=2

CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

prompt_segment() {
    local bg fg

    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"

    if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
        echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
    else
        echo -n "%{$bg%}%{$fg%} "
    fi

    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n $3
}

prompt_end() {
    if [[ -n $CURRENT_BG ]]; then
        echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
    else
        echo -n "%{%k%}"
    fi

    echo -n "%{%f%}"
    CURRENT_BG=''
}

prompt_context() {
    local user=`whoami`

    if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
        prompt_segment black default "%(!.%{%F{yellow}%}.)$user"
    fi
}

fast_git_dirty() {
    [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]] && echo "D"
}

fast_git_untracked() {
    [[ $(git ls-files --other --directory --exclude-standard | gsed q1) ]] && echo "U"
}

fast_git_stashed() {
    [[ $(git rev-parse --verify refs/stash 2> /dev/null | tail -n1) != "" ]] && echo "S"
}

prompt_git() {
    local ref dirty

    if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
        ZSH_THEME_GIT_PROMPT_DIRTY='±'

        dirty=$(fast_git_dirty)
        stashed=$(fast_git_stashed)
        ref=$(git symbolic-ref -q HEAD | sed -e 's|^refs/heads/||')
        commitsAhead=$(git_commits_ahead)
        statusText=""

        # Color of segment
        if [[ -n $dirty || -n $untracked || -n $stashed ]]; then
            prompt_segment yellow black
        else
            prompt_segment green black
        fi

        # Commits ahead
        if [[ -n $commitsAhead ]]; then
            commitsAheadText="(+$commitsAhead)"
            statusText="$statusText$commitsAheadText"
        fi

        # Stashes
        if [[ -n $stashed ]]; then
            stashedText="[$]"
            statusText="$statusText$stashedText"
        fi

        echo -n " $ref $statusText"
    fi
}

prompt_dir() {
    prompt_segment magenta black '%~'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
    local symbols
    symbols=()

    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

    [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompt
build_prompt() {
    RETVAL=$?
    prompt_status
    prompt_context
    prompt_dir
    prompt_git
    prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '