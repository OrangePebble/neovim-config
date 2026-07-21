-- My custom colorscheme for use with the Lush plugin.
-- For usage guides, see :h lush or :LushRunTutorial
-- To see changes on real time on this file, run:
--  `:Lushify` or `:lua require('lush').ify()`
-- Call `:Inspect` to see which highlight-group was chosen.

-- I'll be mostly using the values/methods used in 'https://github.com/EdenEast/nightfox.nvim'.
-- I was using it before but I want more control and an easier and standard way to switch themes.
-- For how they set highlight-groups see:
--  https://github.com/EdenEast/nightfox.nvim/tree/4dacd3f0185a2227bdf3b6c0975a8f0bf87cac9a/lua/nightfox/group
-- For the colors see:
--  https://github.com/EdenEast/nightfox.nvim/blob/4dacd3f0185a2227bdf3b6c0975a8f0bf87cac9a/lua/nightfox/palette/carbonfox.lua

local lush = require("lush")
local hsl = lush.hsl

local bg0 = hsl(vim.g.colorscheme.background_0)
local bg1 = hsl(vim.g.colorscheme.background_1) -- Status line and float
local bg2 = hsl(vim.g.colorscheme.background_2) -- Colorcolm folds
local bg3 = hsl(vim.g.colorscheme.background_3) -- Cursor line
local bg4 = hsl(vim.g.colorscheme.background_4) -- Conceal, border fg
local fg0 = hsl(vim.g.colorscheme.foreground_0)
local fg1 = hsl(vim.g.colorscheme.foreground_1) -- Status line
local fg2 = hsl(vim.g.colorscheme.foreground_2) -- Line numbers, fold colums
local comment = hsl(vim.g.colorscheme.comment)
local sel0 = hsl(vim.g.colorscheme.selection_background_0) -- Popup bg, visual selection bg
local sel1 = hsl(vim.g.colorscheme.selection_background_1) -- Popup sel bg, search bg
local black = hsl(vim.g.colorscheme.black)
local black_bright = hsl(vim.g.colorscheme.black_bright)
local black_dim = hsl(vim.g.colorscheme.black_dim)
local red = hsl(vim.g.colorscheme.red)
local red_bright = hsl(vim.g.colorscheme.red_bright)
local red_dim = hsl(vim.g.colorscheme.red_dim)
local green = hsl(vim.g.colorscheme.green)
local green_bright = hsl(vim.g.colorscheme.green_bright)
local green_dim = hsl(vim.g.colorscheme.green_dim)
local yellow = hsl(vim.g.colorscheme.yellow)
local yellow_bright = hsl(vim.g.colorscheme.yellow_bright)
local yellow_dim = hsl(vim.g.colorscheme.yellow_dim)
local blue = hsl(vim.g.colorscheme.blue)
local blue_bright = hsl(vim.g.colorscheme.blue_bright)
local blue_dim = hsl(vim.g.colorscheme.blue_dim)
local magenta = hsl(vim.g.colorscheme.magenta)
local magenta_bright = hsl(vim.g.colorscheme.magenta_bright)
local magenta_dim = hsl(vim.g.colorscheme.magenta_dim)
local cyan = hsl(vim.g.colorscheme.cyan)
local cyan_bright = hsl(vim.g.colorscheme.cyan_bright)
local cyan_dim = hsl(vim.g.colorscheme.cyan_dim)
local white = hsl(vim.g.colorscheme.white)
local white_bright = hsl(vim.g.colorscheme.white_bright)
local white_dim = hsl(vim.g.colorscheme.white_dim)
local orange = hsl(vim.g.colorscheme.orange)
local orange_bright = hsl(vim.g.colorscheme.orange_bright)
local orange_dim = hsl(vim.g.colorscheme.orange_dim)
local pink = hsl(vim.g.colorscheme.pink)
local pink_bright = hsl(vim.g.colorscheme.pink_bright)
local pink_dim = hsl(vim.g.colorscheme.pink_dim)

-- stylua: ignore
---@diagnostic disable: undefined-global
local theme = lush(function(injected_functions)
  local sym = injected_functions.sym
  return {
    -- The following are the Neovim (as of 0.8.0-dev+100-g371dfb174) highlight
    -- groups, mostly used for styling UI elements.
    -- An empty definition `{}` will clear all styling, leaving elements looking
    -- like the 'Normal' group.
    -- To be able to link to a group, it must already be defined, so you may have
    -- to reorder items as you go.
    --
    -- See :h highlight-groups

    ColorColumn    { bg = bg2 }, -- Columns set with 'colorcolumn'
    Conceal        { fg = bg4 }, -- Placeholder characters substituted for concealed text (see 'conceallevel')
    Cursor         { fg = bg0, bg = fg0 }, -- Character under the cursor
    lCursor        { Cursor }, -- Character under the cursor when |language-mapping| is used (see 'guicursor')
    CursorIM       { Cursor }, -- Like Cursor, but used when in IME mode |CursorIM|
    CursorLine     { bg = bg3 }, -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
    CursorColumn   { CursorLine }, -- Screen-column at the cursor, when 'cursorcolumn' is set.
    Directory      { fg = blue_bright }, -- Directory names (and other special names in listings)
    DiffAdd        { bg = bg0.mix(green_dim, 15) }, -- Diff mode: Added line |diff.txt|
    DiffChange     { bg = bg0.mix(blue_dim, 15) }, -- Diff mode: Changed line |diff.txt|
    DiffDelete     { bg = bg0.mix(red_dim, 15) }, -- Diff mode: Deleted line |diff.txt|
    DiffText       { bg = bg0.mix(cyan_dim, 30) }, -- Diff mode: Changed text within a changed line |diff.txt|
    EndOfBuffer    { fg = bg0 }, -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
    -- TermCursor     { }, -- Cursor in a focused terminal
    -- TermCursorNC   { }, -- Cursor in an unfocused terminal
    ErrorMsg       { fg = red }, -- Error messages on the command line
    Winseparator   { fg = bg1, bg = bg1 }, -- Separator between window splits. Inherts from |hl-VertSplit| by default, which it will replace eventually.
    VertSplit      { Winseparator }, -- Column separating vertically split windows
    Folded         { fg = fg2, bg = bg2 }, -- Line used for closed folds
    FoldColumn     { fg = fg2 }, -- 'foldcolumn'
    SignColumn     { fg = fg2 }, -- Column where |signs| are displayed
    Substitute     { fg = bg0, bg = red }, -- |:substitute| replacement text highlighting
    LineNr         { fg = fg2 }, -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
    -- LineNrAbove    { }, -- Line number for when the 'relativenumber' option is set, above the cursor line
    -- LineNrBelow    { }, -- Line number for when the 'relativenumber' option is set, below the cursor line
    CursorLineNr   { fg = magenta, gui = "bold" }, -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.
    -- CursorLineFold { }, -- Like FoldColumn when 'cursorline' is set for the cursor line
    -- CursorLineSign { }, -- Like SignColumn when 'cursorline' is set for the cursor line
    MatchParen     { fg = magenta, gui = "bold" }, -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
    ModeMsg        { fg = magenta, gui = "bold" }, -- 'showmode' message (e.g., "-- INSERT -- ")
    -- MsgArea        { }, -- Area for messages and cmdline
    -- MsgSeparator   { }, -- Separator for scrolled messages, `msgsep` flag of 'display'
    MoreMsg        { fg = blue, gui = "bold" }, -- |more-prompt|
    NonText        { fg = bg4 }, -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
    Normal         { fg = fg0, bg = bg0 }, -- Normal text
    NormalNC       { fg = fg0, bg = bg0 }, -- normal text in non-current windows
    NormalFloat    { fg = fg0, bg = bg1 }, -- Normal text in floating windows.
    FloatBorder    { fg = fg2, bg = bg1 }, -- Border of floating windows.
    FloatTitle     { fg = blue_bright, bg = bg1, gui = "bold" }, -- Title of floating windows.
    Pmenu          { fg = fg0, bg = sel0 }, -- Popup menu: Normal item.
    PmenuSel       { bg = sel1 }, -- Popup menu: Selected item.
    -- PmenuKind      { }, -- Popup menu: Normal item "kind"
    -- PmenuKindSel   { }, -- Popup menu: Selected item "kind"
    -- PmenuExtra     { }, -- Popup menu: Normal item "extra text"
    -- PmenuExtraSel  { }, -- Popup menu: Selected item "extra text"
    -- PmenuSbar      { }, -- Popup menu: Scrollbar.
    -- PmenuThumb     { }, -- Popup menu: Thumb of the scrollbar.
    Question       { MoreMsg }, -- |hit-enter| prompt and yes/no questions
    QuickFixLine   { CursorLine }, -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
    Search         { fg = fg0, bg = sel1 }, -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
    IncSearch      { fg = bg0, bg = orange }, -- 'incsearch' highlighting; also used for the text replaced with ":s///c"
    CurSearch      { IncSearch }, -- Highlighting a search pattern under the cursor (see 'hlsearch')
    SpecialKey     { NonText }, -- Unprintable characters: text displayed differently from what it really is. But not 'listchars' whitespace. |hl-Whitespace|
    SpellBad       { sp = red, gui = "undercurl" }, -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
    SpellCap       { sp = magenta, gui = "undercurl" }, -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
    SpellLocal     { sp = blue, gui = "undercurl" }, -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
    SpellRare      { sp = blue, gui = "undercurl" }, -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.
    StatusLine     { fg = fg1, bg = bg1 }, -- Status line of current window
    StatusLineNC   { fg = fg2, bg = bg1 }, -- Status lines of not-current windows. Note: If this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
    TabLine        { fg = fg1, bg = bg2 }, -- Tab pages line, not active tab page label
    TabLineFill    { bg = bg1 }, -- Tab pages line, where there are no labels
    TabLineSel     { fg = bg0, bg = fg2 }, -- Tab pages line, active tab page label
    Title          { fg = blue_bright, gui = "bold" }, -- Titles for output from ":set all", ":autocmd" etc.
    Visual         { bg = sel0 }, -- Visual mode selection
    VisualNOS      { Visual }, -- Visual mode selection when vim is "Not Owning the Selection".
    WarningMsg     { fg = red }, -- Warning messages
    Whitespace     { fg = bg3 }, -- "nbsp", "space", "tab" and "trail" in 'listchars'
    WildMenu       { Pmenu }, -- Current match in 'wildmenu' completion
    WinBar         { fg = fg2, bg = bg0, gui = "bold" }, -- Window bar of current window
    WinBarNC       { WinBar }, -- Window bar of not-current windows

    -- Common vim syntax groups used for all kinds of code and markup.
    -- Commented-out groups should chain up to their preferred (*) group
    -- by default.
    --
    -- See :h group-name

    Comment        { fg = comment }, -- Any comment

    Constant       { fg = orange_bright }, -- (*) Any constant
    String         { fg = green }, --   A string constant: "this is a string"
    Character      { String }, --   A character constant: 'c', '\n'
    Number         { fg = orange }, --   A number constant: 234, 0xff
    Float          { Number }, --   A floating point constant: 2.3e10
    Boolean        { Number }, --   A boolean constant: TRUE, false

    Identifier     { fg = cyan }, -- (*) Any variable name
    Function       { fg = blue_bright }, --   Function name (also: methods for classes)

    Statement      { fg = magenta }, -- (*) Any statement
    Conditional    { fg = magenta_bright }, --   if, then, else, endif, switch, etc.
    Repeat         { Conditional }, --   for, do, while, etc.
    Label          { Conditional }, --   case, default, etc.

    Operator       { fg = fg1 }, --   "sizeof", "+", "*", etc.
    Keyword        { fg = magenta }, --   any other keyword
    Exception      { Keyword }, --   try, catch, throw

    PreProc        { fg = pink_bright }, -- (*) Generic Preprocessor
    Include        { PreProc }, --   Preprocessor #include
    Define         { PreProc }, --   Preprocessor #define
    Macro          { PreProc }, --   Same as Define
    PreCondit      { PreProc }, --   Preprocessor #if, #else, #endif, etc.

    Type           { fg = yellow }, -- (*) int, long, char, etc.
    StorageClass   { Type }, --   static, register, volatile, etc.
    Structure      { Type }, --   struct, union, enum, etc.
    Typedef        { Type }, --   A typedef

    Special        { fg = blue_bright }, -- (*) Any special symbol
    SpecialChar    { Special }, --   Special character in a constant
    Tag            { Special }, --   You can use CTRL-] on this
    Delimiter      { Special }, --   Character that needs attention
    SpecialComment { Special }, --   Special things inside a comment (e.g. '\n')
    Debug          { Special }, --   Debugging statements

    Underlined     { gui = "underline" }, -- Text that stands out, HTML links
    -- Ignore         { }, -- Left blank, hidden |hl-Ignore| (NOTE: May be invisible here in template)
    Error          { fg = red }, -- Any erroneous construct
    Todo           { fg = bg0, bg = magenta }, -- Anything that needs extra attention; mostly the keywords TODO FIXME and XXX

    -- These groups are for the native LSP client and diagnostic system. Some
    -- other LSP clients may use these groups, or use their own. Consult your
    -- LSP client's documentation.

    -- See :h lsp-highlight, some groups may not be listed, submit a PR fix to lush-template!

    LspReferenceText            { bg = sel0 }, -- Used for highlighting "text" references
    LspReferenceRead            { bg = sel0 }, -- Used for highlighting "read" references
    LspReferenceWrite           { bg = sel0 }, -- Used for highlighting "write" references
    LspCodeLens                 { fg = comment }, -- Used to color the virtual text of the codelens. See |nvim_buf_set_extmark()|.
    LspCodeLensSeparator        { fg = fg2 }, -- Used to color the seperator between two or more code lens.
    LspSignatureActiveParameter { fg = sel1 }, -- Used to highlight the active parameter in the signature help. See |vim.lsp.handlers.signature_help()|.

    -- See :h diagnostic-highlights, some groups may not be listed, submit a PR fix to lush-template!

    DiagnosticError            { fg = red }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    DiagnosticWarn             { fg = yellow }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    DiagnosticInfo             { fg = blue }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    DiagnosticHint             { fg = magenta }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    DiagnosticOk               { fg = green }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    -- DiagnosticVirtualTextError { }, -- Used for "Error" diagnostic virtual text.
    -- DiagnosticVirtualTextWarn  { }, -- Used for "Warn" diagnostic virtual text.
    -- DiagnosticVirtualTextInfo  { }, -- Used for "Info" diagnostic virtual text.
    -- DiagnosticVirtualTextHint  { }, -- Used for "Hint" diagnostic virtual text.
    -- DiagnosticVirtualTextOk    { }, -- Used for "Ok" diagnostic virtual text.
    DiagnosticUnderlineError   { sp = red, gui = "undercurl" }, -- Used to underline "Error" diagnostics.
    DiagnosticUnderlineWarn    { sp = yellow, gui = "undercurl" }, -- Used to underline "Warn" diagnostics.
    DiagnosticUnderlineInfo    { sp = blue, gui = "undercurl" }, -- Used to underline "Info" diagnostics.
    DiagnosticUnderlineHint    { sp = magenta, gui = "undercurl" }, -- Used to underline "Hint" diagnostics.
    DiagnosticUnderlineOk      { sp = green, gui = "undercurl" }, -- Used to underline "Ok" diagnostics.
    -- DiagnosticFloatingError    { }, -- Used to color "Error" diagnostic messages in diagnostics float. See |vim.diagnostic.open_float()|
    -- DiagnosticFloatingWarn     { }, -- Used to color "Warn" diagnostic messages in diagnostics float.
    -- DiagnosticFloatingInfo     { }, -- Used to color "Info" diagnostic messages in diagnostics float.
    -- DiagnosticFloatingHint     { }, -- Used to color "Hint" diagnostic messages in diagnostics float.
    -- DiagnosticFloatingOk       { }, -- Used to color "Ok" diagnostic messages in diagnostics float.
    -- DiagnosticSignError        { }, -- Used for "Error" signs in sign column.
    -- DiagnosticSignWarn         { }, -- Used for "Warn" signs in sign column.
    -- DiagnosticSignInfo         { }, -- Used for "Info" signs in sign column.
    -- DiagnosticSignHint         { }, -- Used for "Hint" signs in sign column.
    -- DiagnosticSignOk           { }, -- Used for "Ok" signs in sign column.

    -- Tree-Sitter syntax groups.
    --
    -- See :h treesitter-highlight-groups, some groups may not be listed,
    -- submit a PR fix to lush-template!
    --
    -- Tree-Sitter groups are defined with an "@" symbol, which must be
    -- specially handled to be valid lua code, we do this via the special
    -- sym function.
    -- for more details see https://www.lua.org/pil/5.html
    --
    -- For more information see https://github.com/rktjmp/lush.nvim/issues/109

    -- Identifiers ------------------------------------------------------------
    sym"@variable"           { fg = white }, -- various variable names
    sym"@variable.builtin"   { fg = red }, -- built-in variable names (e.g. `this`)
    sym"@variable.parameter" { fg = cyan_bright }, -- parameters of a function
    sym"@variable.member"    { fg = blue }, -- object and struct fields
    sym"@constant"           { Constant }, -- constant identifiers
    sym"@constant.builtin"   { Constant }, -- built-in constant values
    sym"@constant.macro"     { Macro }, -- constants defined by the preprocessor
    sym"@module"             { fg = cyan_dim }, -- modules or namespaces
    -- sym"@module.builtin"     { }, -- built-in modules or namespaces
    sym"@label"              { Label }, -- GOTO and other labels (e.g. `label:` in C), including heredoc labels

    -- Literals ---------------------------------------------------------------
    sym"@string"                { String }, -- string literals
    -- sym"@string.documentation"  { }, -- string documenting code (e.g. Python docstrings)
    sym"@string.regexp"         { fg = yellow_bright }, -- regular expressions
    sym"@string.escape"         { fg = yellow_bright, gui = "bold" }, -- escape sequences
    sym"@string.special"        { Special }, -- other special strings (e.g. dates)
    -- sym"@string.special.symbol" { }, -- symbols or atoms
    sym"@string.special.url"    { fg = orange_bright, gui = "italic,underline" }, -- URIs (e.g. hyperlinks)
    -- sym"@string.special.path"   { }, -- filenames
    sym"@character"             { Character }, -- character literals
    sym"@character.special"     { SpecialChar }, -- special characters (e.g. wildcards)
    sym"@boolean"               { Boolean }, -- boolean literals
    sym"@number"                { Number }, -- numeric literals
    sym"@number.float"          { Float }, -- floating-point number literals

    -- Types ------------------------------------------------------------------
    sym"@type"            { Type }, -- type or class definitions and annotations
    sym"@type.builtin"    { fg = cyan_dim }, -- built-in types
    sym"@type.definition" { sym"@type" }, -- identifiers in type definitions (e.g. `typedef <type> <identifier>` in C)
    sym"@type.qualifier"  { sym"@type" }, -- type qualifiers (e.g. `const`)
    sym"@attribute"       { Constant }, -- attribute annotations (e.g. Python decorators)
    sym"@property"        { fg = blue }, -- the key in key/value pairs

    -- Functions --------------------------------------------------------------
    sym"@function"             { Function }, -- function definitions
    sym"@function.builtin"     { fg = red }, -- built-in functions
    sym"@function.call"        { sym"@function" }, -- function calls
    sym"@function.macro"       { Macro }, -- preprocessor macros
    sym"@function.method"      { sym"@function" }, -- method definitions
    sym"@function.method.call" { sym"@function" }, -- method calls
    sym"@constructor"          { fg = cyan }, -- constructor calls and definitions
    sym"@operator"             { Operator }, -- symbolic operators (e.g. `+` / `*`)

    -- Keywords ---------------------------------------------------------------
    sym"@keyword"                     { Keyword }, -- keywords not fitting into specific categories
    sym"@keyword.coroutine"           { sym"@keyword" }, -- keywords related to coroutines (e.g. `go` in Go, `async/await` in Python)
    sym"@keyword.function"            { fg = magenta }, -- keywords that define a function (e.g. `func` in Go, `def` in Python)
    sym"@keyword.operator"            { fg = fg1 }, -- operators that are English words (e.g. `and` / `or`)
    sym"@keyword.import"              { Include }, -- keywords for including modules (e.g. `import` / `from` in Python)
    sym"@keyword.storage"             { StorageClass }, -- modifiers that affect storage in memory or life-time
    sym"@keyword.repeat"              { Repeat }, -- keywords related to loops (e.g. `for` / `while`)
    sym"@keyword.return"              { fg = red }, -- keywords like `return` and `yield`
    sym"@keyword.debug"               { Debug }, -- keywords related to debugging
    sym"@keyword.exception"           { Exception }, -- keywords related to exceptions (e.g. `throw` / `catch`)
    sym"@keyword.conditional"         { Conditional }, -- keywords related to conditionals (e.g. `if` / `else`)
    sym"@keyword.conditional.ternary" { Conditional }, -- ternary operator (e.g. `?` / `:`)
    -- sym"@keyword.directive"           { }, -- various preprocessor directives & shebangs
    -- sym"@keyword.directive.define"    { }, -- preprocessor definition directives

    -- Punctuation ------------------------------------------------------------
    -- sym"@punctuation"           { Delimiter }, -- Delimiter
    sym"@punctuation.delimiter" { fg = fg1 }, -- delimiters (e.g. `;` / `.` / `,`)
    sym"@punctuation.bracket"   { fg = fg1 }, -- brackets (e.g. `()` / `{}` / `[]`)
    sym"@punctuation.special"   { fg = cyan_bright }, -- special symbols (e.g. `{}` in string interpolation)

    -- Comments ---------------------------------------------------------------
    sym"@comment"               { Comment }, -- line and block comments
    -- sym"@comment.documentation" { link = "" }, -- comments documenting code
    sym"@comment.error"         { fg = bg0, bg = red }, -- error-type comments (e.g. `ERROR`, `FIXME`, `DEPRECATED`)
    sym"@comment.warning"       { fg = bg0, bg = yellow }, -- warning-type comments (e.g. `WARNING`, `FIX`, `HACK`)
    sym"@comment.todo"          { fg = bg0, bg = magenta }, -- todo-type comments (e.g. `TODO`, `WIP`, `FIXME`)
    sym"@comment.note"          { fg = bg0, bg = blue }, -- note-type comments (e.g. `NOTE`, `INFO`, `XXX`)

    -- Markup -----------------------------------------------------------------
    sym"@markup"                { fg = fg0 }, -- For strings considerated text in a markup language.
    sym"@markup.strong"         { fg = red, gui = "bold" }, -- bold text
    sym"@markup.italic"         { gui = "italic" }, -- italic text
    sym"@markup.strikethrough"  { fg = fg0, gui= "strikethrough" }, -- struck-through text
    sym"@markup.underline"      { Underlined }, -- underlined text (only for literal underline markup!)
    sym"@markup.heading"        { Title }, -- headings, titles (including markers)
    sym"@markup.quote"          { fg = fg1 }, -- block quotes
    sym"@markup.math"           { Function }, -- math environments (e.g. `$ ... $` in LaTeX)
    -- sym"@markup.environment"    { }, -- environments (e.g. in LaTeX)
    sym"@markup.link"           { fg = magenta, gui = "bold" }, -- text references, footnotes, citations, etc.
    sym"@markup.link.label"     { Special }, -- link, reference descriptions
    sym"@markup.link.url"       { fg = orange_bright, gui = "italic,underline" }, -- URL-style links
    sym"@markup.raw"            { fg = cyan, gui = "italic" }, -- literal or verbatim text (e.g. inline code)
    sym"@markup.raw.block"      { fg = pink }, -- literal or verbatim text as a stand-alone block (use priority 90 for blocks with injections)
    sym"@markup.list"           { fg = cyan_bright }, -- list markers
    sym"@markup.list.checked"   { fg = green }, -- checked todo-style list markers
    sym"@markup.list.unchecked" { fg = yellow }, -- unchecked todo-style list markers
    sym"@diff.plus"             { fg = green }, -- added text (for diff files)
    sym"@diff.minus"            { fg = red }, -- deleted text (for diff files)
    sym"@diff.delta"            { fg = blue_bright }, -- changed text (for diff files)
    sym"@tag"                   { fg = magenta }, -- XML-style tag names (and similar)
    sym"@tag.attribute"         { fg = blue_bright, gui = "italic" }, -- XML-style tag attributes
    sym"@tag.delimiter"         { fg = cyan_bright }, -- XML-style tag delimiters

    -- Misc -------------------------------------------------------------------
    -- sym"@none" { }, -- completely disable the highlight
    -- sym"@conceal" { }, -- captures that are only meant to be concealed
    -- sym"@spell" { }, -- for defining regions to be spellchecked
    -- sym"@nospell" { }, -- for defining regions that should NOT be spellchecked

    -- Language specific ------------------------------------------------------
    -- json
    sym"@label.json" { fg = blue_bright }, -- For labels: label: in C and :label: in Lua.
    -- lua
    sym"@constructor.lua" { fg = fg1 }, -- Lua's constructor is { }
    -- rust
    sym"@field.rust" { fg = fg1 },
    -- yaml
    sym"@variable.member.yaml" { fg = blue_bright }, -- For fields.

    -- Legacy -----------------------------------------------------------------
    sym"@parameter"             { sym"@variable.parameter" },
    sym"@field"                 { sym"@variable.member" },
    sym"@namespace"             { sym"@module" },
    sym"@float"                 { sym"@number.float" },
    -- sym"@symbol"                { sym"@string.special.symbol" },
    sym"@string.regex"          { sym"@string.regexp" },
    sym"@text"                  { sym"@markup" },
    sym"@text.strong"           { sym"@markup.strong" },
    sym"@text.emphasis"         { sym"@markup.italic" },
    sym"@text.underline"        { sym"@markup.underline" },
    sym"@text.strike"           { sym"@markup.strikethrough" },
    sym"@text.uri"              { sym"@markup.link.url" },
    sym"@text.math"             { sym"@markup.math" },
    -- sym"@text.environment"      { sym"@markup.environment" },
    -- sym"@text.environment.name" { sym"@markup.environment.name" },
    sym"@text.title"            { sym"@markup.heading" },
    sym"@text.literal"          { sym"@markup.raw" },
    sym"@text.reference"        { sym"@markup.link" },
    sym"@text.todo.checked"     { sym"@markup.list.checked" },
    sym"@text.todo.unchecked"   { sym"@markup.list.unchecked" },
    sym"@text.todo"             { sym"@comment.todo" },
    sym"@text.warning"          { sym"@comment.warning" },
    sym"@text.note"             { sym"@comment.note" },
    sym"@text.danger"           { sym"@comment.error" },
    sym"@text.uri"              { sym"@markup.link.uri" },
    sym"@method"                { sym"@function.method" },
    sym"@method.call"           { sym"@function.method.call" },
    sym"@text.diff.add"         { sym"@diff.plus" },
    sym"@text.diff.delete"      { sym"@diff.minus" },
    sym"@define"                { Define },
    sym"@preproc"               { PreProc },
    sym"@macro"                 { Macro },
    sym"@storageclass"          { sym"@keyword.storage" },
    sym"@conditional"           { sym"@keyword.conditional" },
    sym"@exception"             { sym"@keyword.exception" },
    sym"@include"               { sym"@keyword.import" },
    sym"@repeat"                { sym"@keyword.repeat" },
    sym"@structure"             { Structure },
    sym"@debug"                 { sym"@keyword.debug" },
    sym"@error"                 { Error },
    -- sym"@variable.member.yaml"  { sym"@field.yaml" },
    -- sym"@text.title.1.markdown" { sym"@markup.heading.1.markdown" },
    -- sym"@text.title.2.markdown" { sym"@markup.heading.2.markdown" },
    -- sym"@text.title.3.markdown" { sym"@markup.heading.3.markdown" },
    -- sym"@text.title.4.markdown" { sym"@markup.heading.4.markdown" },
    -- sym"@text.title.5.markdown" { sym"@markup.heading.5.markdown" },
    -- sym"@text.title.6.markdown" { sym"@markup.heading.6.markdown" },

    -- LSP semantic tokens
    sym"@lsp.type.boolean"                      { sym"@boolean" },
    sym"@lsp.type.builtinType"                  { sym"@type.builtin" },
    sym"@lsp.type.comment"                      { sym"@comment" },
    sym"@lsp.type.enum"                         { sym"@type" },
    sym"@lsp.type.enumMember"                   { sym"@constant" },
    sym"@lsp.type.escapeSequence"               { sym"@string.escape" },
    sym"@lsp.type.formatSpecifier"              { sym"@punctuation.special" },
    sym"@lsp.type.interface"                    { fg = red_bright },
    sym"@lsp.type.keyword"                      { sym"@keyword" },
    sym"@lsp.type.namespace"                    { sym"@module" },
    sym"@lsp.type.number"                       { sym"@number" },
    sym"@lsp.type.operator"                     { sym"@operator" },
    sym"@lsp.type.parameter"                    { sym"@parameter" },
    sym"@lsp.type.property"                     { sym"@property" },
    sym"@lsp.type.selfKeyword"                  { sym"@variable.builtin" },
    sym"@lsp.type.typeAlias"                    { sym"@type.definition" },
    sym"@lsp.type.unresolvedReference"          { sym"@error" },
    sym"@lsp.type.variable"                     {}, -- use treesitter styles for regular variables
    sym"@lsp.typemod.class.defaultLibrary"      { sym"@type.builtin" },
    sym"@lsp.typemod.enum.defaultLibrary"       { sym"@type.builtin" },
    sym"@lsp.typemod.enumMember.defaultLibrary" { sym"@constant.builtin" },
    sym"@lsp.typemod.function.defaultLibrary"   { sym"@function.builtin" },
    sym"@lsp.typemod.keyword.async"             { sym"@keyword.coroutine" },
    sym"@lsp.typemod.macro.defaultLibrary"      { sym"@function.builtin" },
    sym"@lsp.typemod.method.defaultLibrary"     { sym"@function.builtin" },
    sym"@lsp.typemod.operator.injected"         { sym"@operator" },
    sym"@lsp.typemod.string.injected"           { sym"@string" },
    sym"@lsp.typemod.type.defaultLibrary"       { sym"@type.builtin" },
    sym"@lsp.typemod.variable.defaultLibrary"   { sym"@variable.builtin" },
    sym"@lsp.typemod.variable.injected"         { sym"@variable" },

    -- lazy.nvim
    LazyButtonActive { TabLineSel },
    LazyDimmed       { LineNr },
    LazyProp         { LineNr },

    -- which-key
    WhichKey          { Function },
    WhichKeyGroup     { Identifier },
    WhichKeyDesc      { Keyword },
    WhichKeySeperator { Comment },
    WhichKeySeparator { Comment },
    WhichKeyFloat     { NormalFloat },
    WhichKeyValue     { Comment },

    -- nvim-tree
    NvimTreeNormal            { NormalFloat },
    NvimTreeVertSplit         { VertSplit },
    NvimTreeIndentMarker      { fg = bg4 },
    NvimTreeRootFolder        { fg = comment, gui = "bold" },
    NvimTreeFolderName        { fg = fg1 },
    NvimTreeFolderIcon        { fg = yellow },
    NvimTreeOpenedFolderName  { fg = fg1 },
    NvimTreeEmptyFolderName   { fg = fg2 },
    NvimTreeSymlink           { fg = blue },
    NvimTreeSymlinkFolderName { fg = blue },
    NvimTreeSpecialFile       { fg = cyan },
    NvimTreeImageFile         { fg = white_dim },
    NvimTreeGitDeletedIcon    { fg = red },
    NvimTreeGitDirtyIcon      { fg = yellow },
    NvimTreeGitMergeIcon      { fg = orange },
    NvimTreeGitNewIcon        { fg = green },
    NvimTreeGitRenamedIcon    { fg = magenta },
    NvimTreeGitStagedIcon     { fg = fg0 },

    -- gitsigns
    GitSignsAdd    { fg = green }, -- diff mode: Added line |diff.txt|
    GitSignsChange { fg = yellow }, -- diff mode: Changed line |diff.txt|
    GitSignsDelete { fg = red }, -- diff mode: Deleted line |diff.txt|

    -- mini.icons
    MiniIconsAzure  { fg = blue_bright },
    MiniIconsBlue   { fg = blue },
    MiniIconsCyan   { fg = cyan },
    MiniIconsGreen  { fg = green },
    MiniIconsGrey   { fg = white },
    MiniIconsOrange { fg = orange },
    MiniIconsPurple { fg = magenta },
    MiniIconsRed    { fg = red },
    MiniIconsYellow { fg = yellow },

    -- blink.cmp
    BlinkCmpDoc               { fg = fg0, bg = bg1 },
    BlinkCmpDocBorder         { fg = sel0, bg = bg1 },
    BlinkCmpLabel             { fg = fg0, },
    BlinkCmpLabelDeprecated   { fg = fg2, gui = "strikethrough" },
    BlinkCmpLabelMatch        { fg = blue_bright },
    BlinkCmpKindDefault       { fg = fg1, },
    BlinkCmpLabelDetail       { Comment },
    BlinkCmpKindKeyword       { Identifier },
    BlinkCmpKindVariable      { sym"@variable" },
    BlinkCmpKindConstant      { sym"@constant" },
    BlinkCmpKindReference     { Keyword },
    BlinkCmpKindValue         { Keyword },
    BlinkCmpKindFunction      { Function },
    BlinkCmpKindMethod        { Function },
    BlinkCmpKindConstructor   { Function },
    BlinkCmpKindInterface     { Constant },
    BlinkCmpKindEvent         { Constant },
    BlinkCmpKindEnum          { Constant },
    BlinkCmpKindUnit          { Constant },
    BlinkCmpKindClass         { Type },
    BlinkCmpKindStruct        { Type },
    BlinkCmpKindModule        { sym"@namespace" },
    BlinkCmpKindProperty      { sym"@property" },
    BlinkCmpKindField         { sym"@field" },
    BlinkCmpKindTypeParameter { sym"@field" },
    BlinkCmpKindEnumMember    { sym"@field" },
    BlinkCmpKindOperator      { Operator },
    BlinkCmpKindSnippet       { fg = fg1 },

    -- dap (these are custom and set at ../plugins/dev/dap.lua)
    DapStopped                   { DiagnosticWarn },
    DapStoppedLine               { bg = bg0.mix(yellow, 15) },
    DapBreakpoint                { fg = orange_dim },
    DapBreakpointCondition       { DapBreakpoint },
    DapBreakpointRejected        { DapBreakpoint },
    DapLogPoint                  { DiagnosticInfo },

    -- dapui
    DapUIVariable                { fg = white },
    DapUIScope                   { fg = cyan_bright },
    DapUIType                    { Type },
    DapUIValue                   { fg = white },
    DapUIModifiedValue           { fg = white, gui = "bold" },
    DapUIDecoration              { fg = fg2 },
    DapUIThread                  { String },
    DapUIStoppedThread           { fg = cyan_bright },
    DapUIFrameName               { Normal },
    DapUISource                  { Keyword },
    DapUILineNumber              { Number },
    DapUIFloatBorder             { FloatBorder },
    DapUIWatchesEmpty            { fg = red },
    DapUIWatchesValue            { fg = orange },
    DapUIWatchesError            { fg = red },
    DapUIBreakpointsPath         { fg = cyan_bright },
    DapUIBreakpointsInfo         { fg = blue },
    DapUIBreakpointsCurrentLine  { fg = magenta, gui = "bold" },
    DapUIBreakpointsLine         { DapUILineNumber },
    DapUIBreakpointsDisabledLine { fg = comment },

    -- neotest
    NeotestPassed       { fg = green },
    NeotestFailed       { fg = red },
    NeotestRunning      { fg = magenta },
    NeotestSkipped      { fg = yellow },
    NeotestTest         { Normal},
    NeotestNamespace    { fg = cyan_dim },
    NeotestMarked       { fg = fg0, gui = 'bold' },
    NeotestFocused      { gui = 'underline' },
    NeotestFile         { fg = blue },
    NeotestDir          { fg = cyan },
    NeotestIndent       { Conceal },
    NeotestExpandMarker { Conceal },
    NeotestAdapterName  { fg = pink, gui = 'bold'},

    -- Overseer
    OverseerPENDING    { Comment },
    OverseerRUNNING    { Normal },
    OverseerSUCCESS    { DiagnosticOk },
    OverseerCANCELED   { DiagnosticWarn },
    OverseerFAILURE    { DiagnosticError },
    OverseerDISPOSED   { Conceal },
    OverseerTask       { Title },
    OverseerTaskBorder { FloatBorder },
    OverseerOutput     { Normal },
    OverseerComponent  { Constant },
    OverseerField      { Keyword },
  }
end)

-- Return our parsed theme for extension or use elsewhere.
return theme

-- vi:nowrap
