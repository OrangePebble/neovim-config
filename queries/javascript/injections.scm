; extends

; Inject any template literal immediately preceded by /*html*/.
(_
  (comment) @_marker
  .
  (template_string) @injection.content
  (#eq? @_marker "/*html*/")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "html"))

; Inject any template literal immediately preceded by /*css*/.
(_
  (comment) @_marker
  .
  (template_string) @injection.content
  (#eq? @_marker "/*css*/")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "css"))
