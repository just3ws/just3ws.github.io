_audit_public_surface_completions() {
  local opts="--json --verbose --strict --report-dir --decide --man --completion --help"
  COMPREPLY=( $(compgen -W "$opts" -- "${COMP_WORDS[COMP_CWORD]}") )
}

complete -F _audit_public_surface_completions audit_public_surface.rb
