
PATH="/Library/Frameworks/Python.framework/Versions/3.10/bin:${PATH}"
PATH="$HOME/bin:$PATH"
export PATH


# make "help" do something useful, like in bash
unalias run-help 2>/dev/null
autoload -Uz run-help
alias help=run-help
HELPDIR=/usr/share/zsh/${ZSH_VERSION}/help

# initialize the completion system
autoload -Uz compinit && compinit

# set up the version control info part of the prompt using the vcs_info package
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn hg
precmd() {
    vcs_info
    psvar[1]=${vcs_info_msg_0_}
}
# choose a rather minimal set of information to display (just the branch).
# See https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#vcs_005finfo-Configuration
zstyle ':vcs_info:git*' formats '%b'
zstyle ':vcs_info:git*' actionformats '%b (%a)'

# set the prompt.  This is the default prompt we are overriding:
# PROMPT='%n@%m %1~ %# '
#
# Here's what each part of the prompt string does:
# Print a red X (and space) if the exit status of the last command was not 0
#   %(?..%F{red}\u2718%f )
# Machine name
#   %m:
# Path from $HOME, in bold
#   %B%~%b
# VCS info.  If psvar[1] is set and non-empty (see precmd, above), then
# print it inside brackets.
#   %(1V.[%1v].)
# Print a little gear icon if there are any background jobs running
#   %(1j.\u2699.)
# Print "#" if the shell is "priviledged", otherwise "%"
#   %#
# See https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html for a
# full description of the prompt escape sequences
PROMPT=$'%(?..%F{red}\u2718%f )%m:%B%~%b %(1V.[%1v].)%(1j.\u2699.)%# '

# additional notes for prompt strings:
# symbols used in https://github.com/agnoster/agnoster-zsh-theme
# echo "\ue0b0 \u00b1 \ue0a0 \u27a6 \u2718 \u26a1 \u2669
# some alternatives for the symbol used for branch:
# echo "\ua768 \ua769"

# we don't actually use any variable substitutions in the prompt, since we
# set psvar in the precmd instead.  But if we did, then we would need to
# enable PROMPT_SUBST:
# setopt PROMPT_SUBST
#

# Make word-based navigation and deletion work like I expect
WORDCHARS=

export EDITOR=emacs

# make "history" show the full history like in bash
alias history='history 1'
HISTSIZE=20000
SAVEHIST=10000

