; extends

; This highlights the `@` directives and their values in userscripts.
; Because the JavaScript parser treats comments as opaque nodes we need some jank.
; In order to highlight different sections in the same line different colors we need to
;  use `offset`, but unlike `match` where we can use a flexible regex, it needs a specific integer.
; But directives can have varying sizes so we need a different query for each length of directive.
; These queries first highlight everything but the starting `// ` the color of the directive,
;  then color everything but the starting `// ` and the directive the color of the value.
; I'm currently accepting directive lengths 3 through 15.

((comment) @keyword.import
  (#match? @keyword.import "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{2,14}(\\s|$)")
  (#offset! @keyword.import 0 3 0 0)
  (#set! priority 101))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{2}\\s")
  (#offset! @string 0 7 0 0)
  (#set! priority 102))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{3}\\s")
  (#offset! @string 0 8 0 0)
  (#set! priority 102))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{4}\\s")
  (#offset! @string 0 9 0 0)
  (#set! priority 102))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{5}\\s")
  (#offset! @string 0 10 0 0)
  (#set! priority 102))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{6}\\s")
  (#offset! @string 0 11 0 0)
  (#set! priority 102))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{7}\\s")
  (#offset! @string 0 12 0 0)
  (#set! priority 102))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{8}\\s")
  (#offset! @string 0 13 0 0)
  (#set! priority 102))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{9}\\s")
  (#offset! @string 0 14 0 0)
  (#set! priority 102))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{10}\\s")
  (#offset! @string 0 15 0 0)
  (#set! priority 102))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{11}\\s")
  (#offset! @string 0 16 0 0)
  (#set! priority 102))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{12}\\s")
  (#offset! @string 0 17 0 0)
  (#set! priority 102))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{13}\\s")
  (#offset! @string 0 18 0 0)
  (#set! priority 102))

((comment) @string
  (#match? @string "\\v^// \\@[A-Za-z][A-Za-z0-9:_-]{14}\\s")
  (#offset! @string 0 19 0 0)
  (#set! priority 102))
