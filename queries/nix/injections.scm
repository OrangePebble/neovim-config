; extends

; Inject an indented string immediately preceded by #bash.
(_
  (comment) @_marker
  .
  (indented_string_expression) @injection.content
  (#eq? @_marker "#bash")
  (#offset! @injection.content 0 2 0 -2)
  (#set! injection.include-children)
  (#set! injection.language "bash"))
