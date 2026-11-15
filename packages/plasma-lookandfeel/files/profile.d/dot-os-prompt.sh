# DOT OS shell prompt: `user@host ~ >` in the secondary text colour; the `>`
# turns red when the last command failed. In a graphical terminal it also
# sets the title to the working directory in capitals, which Konsole shows on
# its tabs. PROMPT_COMMAND is exported so that bash in a terminal picks it up
# even though ~/.bashrc sets its own PS1.
PROMPT_COMMAND='__dot=$?; case "$TERM" in linux|dumb|"") ;; *) __dir="${PWD/#$HOME/\~}"; printf "\033]2;%s\007" "${__dir^^}";; esac; if [ $__dot -eq 0 ]; then PS1="\[\e[2m\]\u@\h \w >\[\e[0m\] "; else PS1="\[\e[2m\]\u@\h \w \[\e[0;31m\]>\[\e[0m\] "; fi'
export PROMPT_COMMAND
