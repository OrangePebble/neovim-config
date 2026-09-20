; extends

; Inject an indented string immediately preceded by a comment containing only
; "bash" plus optional whitespace.
(_
  (comment) @_marker
  .
  (indented_string_expression) @injection.content
  (#match? @_marker "^#[[:space:]]*bash[[:space:]]*$")
  (#offset! @injection.content 0 2 0 -2)
  (#set! injection.include-children)
  (#set! injection.language "bash"))
