# modify prompt from bash-it pure theme to suite my needs

pure_prompt() {
    ps_host="${bold_blue}\h${normal}";
    ps_user="${green}\u${normal}";
    ps_user_mark="${green} \n$ ${normal}";
    ps_root="${red}\u${red}";
    ps_root_mark="${red} \n# ${normal}"
    ps_path="${yellow}\w${normal}";

    # make it work
    case $(id -u) in
        0) PS1="$(virtualenv_prompt)$ps_root@$ps_host$(scm_prompt):$ps_path$ps_root_mark"
            ;;
        *) PS1="$(virtualenv_prompt)$ps_user@$ps_host$(scm_prompt):$ps_path$ps_user_mark"
            ;;
    esac
}

if test "$BASH_IT_THEME" = "pure" ;  then
    safe_append_prompt_command pure_prompt
fi
