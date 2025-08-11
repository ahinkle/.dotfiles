# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Editor

# PHP
alias c="composer"
alias cu="composer update"
alias ci="composer install"
alias pst="./vendor/bin/phpstan analyse --memory-limit=2G"
alias pint='./vendor/bin/pint'
alias pest='./vendor/bin/pest'
# Laravel
alias pa="php artisan"
alias pu="./vendor/bin/phpunit -d memory_limit=2048M"
alias pup="php artisan test -p"
alias mfs="php artisan migrate:fresh --seed"
alias viewlog='tail -f -n 450 storage/logs/laravel*.log \
                | grep -i -E \
                    "^\[\d{4}\-\d{2}\-\d{2} \d{2}:\d{2}:\d{2}\]|Next [\w\W]+?\:" \
                    --color'
# Node / NPM
alias ni="npm install"
alias nu="npm update"

# Git
alias ff='git pull --ff-only'
alias gpo="git pull origin"
alias nah='git reset --hard;git clean -df'
alias wip='git add . && git commit -m "wip"'
# Switches from the current branch to the main branch, resets the main branch, and deletes the previous branch.
function switch_to_origin_and_reset() {
    # Get the name of the current branch
    local current_branch="$(git rev-parse --abbrev-ref HEAD)"

    # Switch to 'main' or 'master' brancht
    if git rev-parse --verify main &>/dev/null; then
        git checkout main
    elif git rev-parse --verify master &>/dev/null; then
		echo "Main branch not found, switching to master. Recommend creating a main branch."
        git checkout master
    elif git rev-parse --verify staging &>/dev/null; then
        git checkout staging
    else
        echo "Neither 'main' nor 'master' nor 'staging' branch found."
        return 1
    fi

    # Delete the previous feature branch, if it's not the current branch
    if [[ $current_branch != "main" && $current_branch != "master" && $current_branch != "staging" ]]; then
        git branch -d "$current_branch"
    fi

    # Pull the latest changes with --ff-only flag
    git pull --ff-only
}
alias origin='switch_to_origin_and_reset'
alias repo='gh repo view --web'
cpr() {
    branch=$(git rev-parse --abbrev-ref HEAD)
    remote=$(git remote)
    
    # Check if we have uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        read -p "You have uncommitted changes. Continue anyway? (y/n): " confirm
        if [[ $confirm != "y" ]]; then
            echo "Aborted PR creation."
            return 1
        fi
    fi
    
    # Check for unpushed commits
    if git log ${remote}/$(git symbolic-ref --short HEAD)..HEAD | grep -q .; then
        echo "Pushing unpushed commits..."
        git push -u $remote $branch
    fi
    
    # Open PR creation page
    gh pr create --web
}

checks() {
    local pr_number="$1"
    local repo_flag=""
    
    # If no PR number provided, try to get current PR
    if [[ -z "$pr_number" ]]; then
        pr_number=$(gh pr view --json number --jq '.number' 2>/dev/null)
        if [[ -z "$pr_number" ]]; then
            echo "No PR number provided and not in a PR branch"
            return 1
        fi
    fi
    
    # Add repo flag if we're not in the repo directory
    if [[ -n "$2" ]]; then
        repo_flag="--repo $2"
    fi
    
    # Get check results
    local output=$(gh pr checks $pr_number $repo_flag 2>/dev/null)
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        echo "Failed to fetch PR checks"
        return 1
    fi
    
    # Count different check statuses
    local total=$(echo "$output" | wc -l)
    local passed=$(echo "$output" | grep -c "✓" || echo "0")
    local failed=$(echo "$output" | grep -c "✗" || echo "0")
    local pending=$(echo "$output" | grep -cE "(pending|⏳|○)" || echo "0")
    
    # Determine status and provide feedback
    if [[ $failed -gt 0 ]]; then
        echo "❌ $failed/$total checks failed"
        echo "$output"
    elif [[ $pending -gt 0 ]]; then
        echo "⏳ $passed/$total checks complete (${pending} running)"
        echo "$output"
    else
        echo "✅ All GitHub Actions Passing ($total/$total)"
    fi
}

# SSH
alias copysshkey='command cat ~/.ssh/id_rsa.pub | pbcopy'
alias sshgn="ssh forge@173.249.71.94"

# MySQL
function mkdatabase() {
    if [ -z "$1" ]; then
        echo "Please provide a database name"
        return 1
    fi

    mysql -h 127.0.0.1 -u root -P 3306 --socket="/Users/ahinkle/Library/Application Support/Herd/config/services/377A633D-7EFC-4BDC-A5A6-F4C588DFAF95/" -e "DROP DATABASE IF EXISTS $1;"
    mysql -h 127.0.0.1 -u root -P 3306 --socket="/Users/ahinkle/Library/Application Support/Herd/config/services/377A633D-7EFC-4BDC-A5A6-F4C588DFAF95/" -e "CREATE DATABASE $1;"
    
    echo "Database '$1' created successfully"
}

alias mkdb='mkdatabase'

# AI
alias cl="claude --dangerously-skip-permissions"

# Neovim
alias t='tmux'
alias ta="tmux attach -t"


# Python 3 
export PYTHON=$(which python3)

# Herd injected NVM configuration
export NVM_DIR="/Users/ahinkle/Library/Application Support/Herd/config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[[ -f "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh" ]] && builtin source "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh"


# Herd injected PHP binary.
export PATH="/Users/ahinkle/Library/Application Support/Herd/bin/":$PATH


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/ahinkle/Library/Application Support/Herd/config/php/84/"


# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/ahinkle/Library/Application Support/Herd/config/php/83/"
export PATH="$PATH:/Users/ahinkle/pear/bin"
export JAVA_HOME=$(/usr/libexec/java_home)

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin


# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/ahinkle/Library/Application Support/Herd/config/php/82/"
