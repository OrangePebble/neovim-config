; extends

; Inject any template literal immediately preceded by a comment containing
; only "html" plus whitespace and comment delimiters. Block markers may share
; a line with the template; // markers must be on their own.
(_
  (comment) @_marker
  .
  (template_string) @injection.content
  (#match? @_marker "^[/*[:space:]]*html[/*[:space:]]*$")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "html"))

; Inject any template literal immediately preceded by a comment containing
; only "css" plus whitespace and comment delimiters. Block markers may share
; a line with the template; // markers must be on their own.
(_
  (comment) @_marker
  .
  (template_string) @injection.content
  (#match? @_marker "^[/*[:space:]]*css[/*[:space:]]*$")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "css"))
