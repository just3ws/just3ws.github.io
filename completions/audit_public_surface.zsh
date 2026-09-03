#compdef audit_public_surface.rb

_audit_public_surface() {
  _arguments \
    '--json[emit a redacted JSON report]' \
    '--verbose[print every redacted finding]' \
    '--strict[fail on unresolved high-risk findings]' \
    '--report-dir[write local reports under PATH]:path:_directories' \
    '--decide[record a local review decision]:decision:' \
    '--man[print the manual page]' \
    '--completion[print shell completion]:shell:(zsh bash)' \
    '--help[show help]'
}

_audit_public_surface "$@"
