# kubecheck.sh completion                                  -*- shell-script -*-

# This bash completions script was generated by
# completely (https://github.com/dannyben/completely)
# Modifying it manually is not recommended

_kubecheck.sh_completions_filter() {
  local words="$1"
  local cur=${COMP_WORDS[COMP_CWORD]}
  local result=()

  if [[ "${cur:0:1}" == "-" ]]; then
    echo "$words"

  else
    for word in $words; do
      [[ "${word:0:1}" != "-" ]] && result+=("$word")
    done

    echo "${result[*]}"

  fi
}

_kubecheck.sh_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local compwords=("${COMP_WORDS[@]:1:$COMP_CWORD-1}")
  local compline="${compwords[*]}"

  case "$compline" in
    'pod'*'-n')
      while read -r; do COMPREPLY+=("$REPLY"); done < <(compgen -W "$(_kubecheck.sh_completions_filter "$(kubectl get namespaces --no-headers -o custom-columns=":metadata.name")")" -- "$cur")
      ;;

    'pod'*)
      while read -r; do COMPREPLY+=("$REPLY"); done < <(compgen -W "$(_kubecheck.sh_completions_filter "$(kubectl get pods -A --no-headers -o custom-columns=":metadata.name")")" -- "$cur")
      ;;

    *)
      while read -r; do COMPREPLY+=("$REPLY"); done < <(compgen -W "$(_kubecheck.sh_completions_filter "refresh storage lastreboot processes performance cluster storage cleanstorage network pod clusterprogress")" -- "$cur")
      ;;

  esac
} &&
  complete -F _kubecheck.sh_completions kubecheck.sh

# ex: filetype=sh
