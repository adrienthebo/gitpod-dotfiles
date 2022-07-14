pathmunge() {
        if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" ; then
           if [ "$2" = "after" ] ; then
              PATH=$PATH:$1
           else
              PATH=$1:$PATH
           fi
        fi
}

pathmunge "$HOME/.local/bin" after
pathmunge "$HOME/.krew/bin" after

[[ -f $HOME/.asdf/asdf.sh ]] && source $HOME/.asdf/asdf.sh