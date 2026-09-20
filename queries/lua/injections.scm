; extends

; Inject a Lua string used as a table field when the preceding comment's
; content is only "bash" plus optional whitespace. Capturing string content
; excludes all Lua string delimiters, so this works for quoted strings as well
; as [[...]] and [=[...]=] long strings.
(
  (table_constructor
    (comment
      (comment_content) @_marker)
    .
    (field
      (string
        content: (_) @injection.content)))
  (#match? @_marker "^[[:space:]]*bash[[:space:]]*$")
  (#set! injection.language "bash"))
