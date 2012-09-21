#
# Bash completion for Leaf Bering-uClibc
#
# Copyright (C) 2012 Yves Blusseau

# This function generates completion reply with compgen
# - arg: accepts 1, 2, 3, or 4 arguments
#        $1 wordlist separate by space, tab or newline
#        $2 (optional) prefix to add
#        $3 (optional) current word to complete
#        $4 (optional) suffix to add
__buccomp () {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [ $# -gt 2 ]; then
        cur="$3"
    fi
    case "$cur" in
    --*=)
        COMPREPLY=()
        ;;
    *)
        local IFS=' '$'\t'$'\n'
        COMPREPLY=($(compgen -P "${2-}" -W "${1-}" -S "${4-}" -- "$cur"))
        ;;
    esac
}

#
# buildtool.pl
#
_buildtool () {
    local cur prev split=false

    COMPREPLY=()
    cur=`_get_cword`
    prev=${COMP_WORDS[COMP_CWORD-1]}

    _split_longopt && split=true

    case "$prev" in
        distclean|maketar)
            return
            ;;
        list)
            __buccomp "sourced built"
            return
            ;;
        describe|dumpenv|build|source|pkglist|remove)
            local prog=${COMP_WORDS[0]}
            __buccomp "$(LC_ALL=C $prog pkglist | sed 's/,/ /g')"
            return
            ;;
        buildclean)
            local prog=${COMP_WORDS[0]}
            __buccomp "$(LC_ALL=C $prog list built)"
            return
            ;;
        srcclean)
            local prog=${COMP_WORDS[0]}
            __buccomp "$(LC_ALL=C $prog list sourced)"
            return
            ;;
        -t)
            # Need to find a way to list available toolchain
            return
            ;;
    esac

    $split && return 0

    if [[ "$cur" == -* ]]; then
        __buccomp "-v -f -O -D -d -t"
    else
        # Default commands
        __buccomp "describe list dumpenv source build pkglist buildclean
                   srcclean remove distclean maketar"
    fi
}

complete -F _buildtool buildtool.pl


#
# buildpacket.pl
#
_buildpacket () {
    local cur prev split=false

    COMPREPLY=()
    cur=`_get_cword`
    prev=${COMP_WORDS[COMP_CWORD-1]}

    _split_longopt && split=true

    case "$prev" in
        --packager|--target|--lrp|--toolchain)
            # option need a value
            return
            ;;
        --package)
            local prog=${COMP_WORDS[0]}
            # buildtool.pl must be in the same directory that buildpacket.pl
             __buccomp "$(LC_ALL=C ${prog/buildpacket/buildtool} list built)"
            return
            ;;
    esac

    $split && return 0

    if [[ "$cur" == -* ]]; then
        __buccomp "--package --packager --target --lrp --verbose --sign --toolchain"
    fi
}

complete -F _buildpacket buildpacket.pl
