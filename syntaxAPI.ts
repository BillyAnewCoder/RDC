// syntaxAPI.ts
// Comprehensive unified Lua 5.1 + Luau + Synapse X Syntax API for AI reference

export interface SyntaxRule {
  /** Human‑readable name for the syntax rule */
  name: string
  /** Primary category (helps AI classify rules) */
  category:
    | 'keyword'
    | 'operator'
    | 'literal'
    | 'identifier'
    | 'comment'
    | 'control'
    | 'expression'
    | 'function'
    | 'metaprogramming'
    | 'grammar'
  /** Short description of the rule */
  description: string
  /** Formal grammar in EBNF form, if available */
  grammar?: string
  /** Regex pattern (as string) to match this syntax */
  pattern?: string
  /** Only valid in Luau (Roblox) */
  luauOnly?: boolean
  /** Only available in Synapse X exploit environment */
  synapseOnly?: boolean
  /** Whether code using this rule is valid, invalid, or deprecated */
  classification: 'valid' | 'invalid' | 'deprecated'
}

export const syntaxAPI: SyntaxRule[] = [
  // COMMENTS
  {
    name: 'Single‑line comment',
    category: 'comment',
    description: 'Starts with “--” and continues to end of line',
    pattern: '^--.*$',
    grammar: `comment ::= "--" { any_char_except_newline }`,
    classification: 'valid'
  },
  {
    name: 'Multi‑line comment',
    category: 'comment',
    description: 'Enclosed between “--[[” and “]]”',
    pattern: '^--\\[\\[[\\s\\S]*?\\]\\]$',
    grammar: `comment ::= "--[[" { any_char } "]]"`,
    classification: 'valid'
  },

  // LITERALS
  {
    name: 'nil literal',
    category: 'literal',
    description: 'Represents the absence of a useful value',
    pattern: '\\bnil\\b',
    classification: 'valid'
  },
  {
    name: 'boolean literal',
    category: 'literal',
    description: 'true or false',
    pattern: '\\b(true|false)\\b',
    classification: 'valid'
  },
  {
    name: 'number literal',
    category: 'literal',
    description: 'Decimal or hexadecimal number',
    pattern: '\\b0x[0-9A-Fa-f]+\\b|\\b\\d+(?:\\.\\d*)?(?:[eE][+-]?\\d+)?\\b',
    classification: 'valid'
  },
  {
    name: 'string literal',
    category: 'literal',
    description: 'Single‑ or double‑quoted strings',
    pattern: `"(?:\\\\.|[^"\\\\])*"|'(?:\\\\.|[^'\\\\])*'`,
    classification: 'valid'
  },

  // IDENTIFIERS
  {
    name: 'identifier',
    category: 'identifier',
    description: 'Names for variables, functions, tables, etc.',
    pattern: '\\b[A-Za-z_][A-Za-z0-9_]*\\b',
    grammar: `identifier ::= letter | "_" { letter | digit | "_" }`,
    classification: 'valid'
  },

  // KEYWORDS
  ...[
    'and','break','do','else','elseif','end','false','for','function','if',
    'in','local','nil','not','or','repeat','return','then','true','until','while'
  ].map(kw => ({
    name: `keyword “${kw}”`,
    category: 'keyword' as const,
    description: `Lua 5.1 reserved word`,
    pattern: `\\b${kw}\\b`,
    classification: 'valid'
  })),
  {
    name: 'continue',
    category: 'keyword',
    description: 'Skips to next iteration (Luau only)',
    pattern: '\\bcontinue\\b',
    luauOnly: true,
    classification: 'valid'
  },
  {
    name: 'type',
    category: 'keyword',
    description: 'Type alias declaration (Luau only)',
    pattern: '\\bexport\\s+type\\b|\\btype\\b',
    luauOnly: true,
    classification: 'valid'
  },
  {
    name: 'export',
    category: 'keyword',
    description: 'Marks export in module (Luau only)',
    pattern: '\\bexport\\b',
    luauOnly: true,
    classification: 'valid'
  },

  // OPERATORS
  ...[
    { op: '\\+', desc: 'Addition' },
    { op: '\\-', desc: 'Subtraction or unary minus' },
    { op: '\\*', desc: 'Multiplication' },
    { op: '/', desc: 'Division' },
    { op: '%', desc: 'Modulo' },
    { op: '\\^', desc: 'Exponentiation' },
    { op: '#', desc: 'Length operator or vararg in grammar' },
    { op: '\\.', desc: 'Member or concatenation start' },
    { op: '\\.\\.', desc: 'Concatenation' },
    { op: '==', desc: 'Equality' },
    { op: '~=', desc: 'Inequality' },
    { op: '<=', desc: 'Less or equal' },
    { op: '>=', desc: 'Greater or equal' },
    { op: '<', desc: 'Less than' },
    { op: '>', desc: 'Greater than' },
    { op: '=', desc: 'Assignment or equals in grammar' },
    { op: '\\(', desc: 'Grouping or call start' },
    { op: '\\)', desc: 'Grouping or call end' },
    { op: '\\{', desc: 'Table constructor start' },
    { op: '\\}', desc: 'Table constructor end' },
    { op: '\\[', desc: 'Index or literal table key start' },
    { op: '\\]', desc: 'Index or literal table key end' },
    { op: ';', desc: 'Statement separator' },
    { op: ':', desc: 'Method definition or label' },
    { op: ',', desc: 'List separator' },
    { op: '\\?\\?', desc: 'Coalesce (Luau only)', luauOnly: true },
    { op: '//', desc: 'Floor division (Luau only)', luauOnly: true }
  ].map(o => ({
    name: `operator “${o.op.replace(/\\\\/g,'\\')}”`,
    category: 'operator' as const,
    description: o.desc,
    pattern: o.op,
    luauOnly: !!o.luauOnly,
    classification: 'valid'
  })),
  {
    name: 'compound assignment',
    category: 'operator',
    description: 'e.g. +=, -=, *=, /=, //=, ..= (Luau only)',
    pattern: '\\+=|\\-=|\\*=|/=|//=|%=|\\^=|\\.\\.=',
    luauOnly: true,
    classification: 'valid'
  },

  // CONTROL STRUCTURES (EBNF)
  {
    name: 'if statement',
    category: 'control',
    description: 'Conditional branching',
    grammar: `
if_statement ::= "if" expression "then" block {
    "elseif" expression "then" block
} [ "else" block ] "end"
    `.trim(),
    pattern: '\\bif\\b[\\s\\S]+?\\bend\\b',
    classification: 'valid'
  },
  {
    name: 'while loop',
    category: 'control',
    description: 'Pre‑test loop',
    grammar: `while_loop ::= "while" expression "do" block "end"`,
    pattern: '\\bwhile\\b[\\s\\S]+?\\bend\\b',
    classification: 'valid'
  },
  {
    name: 'repeat loop',
    category: 'control',
    description: 'Post‑test loop',
    grammar: `repeat_loop ::= "repeat" block "until" expression`,
    pattern: '\\brepeat\\b[\\s\\S]+?\\buntil\\b',
    classification: 'valid'
  },
  {
    name: 'numeric for loop',
    category: 'control',
    description: 'for i = init, limit [, step] do ... end',
    grammar: `numeric_for ::= "for" Name "=" exp1 "," exp2 ["," exp3] "do" block "end"`,
    pattern: '\\bfor\\s+[A-Za-z_][A-Za-z0-9_]*\\s*=.+?\\bend\\b',
    classification: 'valid'
  },
  {
    name: 'generic for loop',
    category: 'control',
    description: 'for k,v in iterator() do ... end',
    grammar: `generic_for ::= "for" name_list "in" exp_list "do" block "end"`,
    pattern: '\\bfor\\s+.+?\\bin\\b.+?\\bend\\b',
    classification: 'valid'
  },
  {
    name: 'break',
    category: 'control',
    description: 'Exit innermost loop',
    pattern: '\\bbreak\\b',
    classification: 'valid'
  },

  // FUNCTIONS
  {
    name: 'function definition',
    category: 'function',
    description: 'Defines a named or anonymous function',
    grammar: `
funcdef ::= "function" funcname funcbody
funcname ::= Name { "." Name } [ ":" Name ]
funcbody ::= "(" [ parlist ] ")" block "end"
    `.trim(),
    pattern: '\\bfunction\\b[\\s\\S]+?\\bend\\b',
    classification: 'valid'
  },
  {
    name: 'anonymous function',
    category: 'function',
    description: 'Function value expression',
    grammar: `anonfunc ::= "function" "(" [parlist] ")" block "end"`,
    pattern: 'function\\s*\\(',
    classification: 'valid'
  },
  {
    name: 'varargs',
    category: 'expression',
    description: 'Represents variable number of args (“...”)',
    pattern: '\\.\\.\\.',
    classification: 'valid'
  },

  // TABLE
  {
    name: 'table constructor',
    category: 'expression',
    description: 'Defines a table literal',
    grammar: `
tableconstructor ::= "{" [fieldlist] "}"
fieldlist ::= field { fieldsep field } [fieldsep]
field ::= "[" exp "]" "=" exp | Name "=" exp | exp
fieldsep ::= "," | ";"
    `.trim(),
    pattern: '\\{[\\s\\S]*?\\}',
    classification: 'valid'
  },

  // MODULE/REQUIRE
  {
    name: 'require',
    category: 'function',
    description: 'Loads a ModuleScript (Roblox) or chunk (Lua)',
    pattern: '\\brequire\\s*\\(',
    classification: 'valid'
  },

  // LUau TYPE ANNOTATIONS
  {
    name: 'parameter type annotation',
    category: 'grammar',
    description: 'function foo(x: number): string',
    pattern: '\\w+\\s*:\\s*[%a_][%w_<>]*',
    luauOnly: true,
    classification: 'valid'
  },
  {
    name: 'return type annotation',
    category: 'grammar',
    description: 'function foo(): Type',
    pattern: '\\)\\s*:\\s*[%a_][%w_<>]*',
    luauOnly: true,
    classification: 'valid'
  },

  // PATTERNS (Lua‑style)
  {
    name: 'pattern matching special char',
    category: 'grammar',
    description: 'Lua patterns (e.g. “%a”, “%d”, “.”, “*”, “+”)',
    pattern: '%\\w|[%.%*%+%-%?%[%]%^%$]',
    classification: 'valid'
  },

  // INVALID/DEPRECATED
  {
    name: 'goto',
    category: 'keyword',
    description: '“goto” not supported in Lua 5.1 (deprecated)',
    pattern: '\\bgoto\\b',
    classification: 'invalid'
  },
  {
    name: 'function with vararg before named params',
    category: 'grammar',
    description: '“function(a, ..., b)” invalid in Lua 5.1',
    pattern: 'function\\s*\\(.*\\.\\.\\..*,.*\\)',
    classification: 'invalid'
  },

  // SYNAPSE X METAPROGRAMMING FUNCTIONS
  ...[
    'getgenv','getrenv','getreg','getgc','getinstances','getnilinstances',
    'getscripts','getloadedmodules','getconnections','firesignal','fireclickdetector',
    'firetouchinterest','getsenv','getcallingscript','getrawmetatable',
    'setrawmetatable','setreadonly','isreadonly','isrbxactive','keypress',
    'keyrelease','mouse1click','mouse1press','mouse1release','mouse2click',
    'mousedownrel','mousemoveabs','hookfunction','hookmetamethod','newcclosure',
    'loadstring','checkcaller','iscclosure','islclosure','dumpstring','decompile'
  ].map(fn => ({
    name: `Synapse X function “${fn}”`,
    category: 'metaprogramming' as const,
    description: `Exploit‐only function ${fn}()`,
    pattern: `\\b${fn}\\s*\\(`,
    synapseOnly: true,
    classification: 'valid'
  })),

  // DEBUG EXTENSIONS
  ...[
    'debug.getconstants','debug.getconstant','debug.setconstant',
    'debug.getupvalue','debug.setupvalue','debug.getprotos','debug.getproto',
    'debug.setproto','debug.getstack','debug.setstack','debug.getlocals',
    'debug.getlocal','debug.setlocal'
  ].map(fn => ({
    name: `Synapse debug extension “${fn}”`,
    category: 'metaprogramming' as const,
    description: `Debug library extension for ${fn}`,
    pattern: `\\b${fn.replace('.', '\\\\.')}\\s*\\(`,
    synapseOnly: true,
    classification: 'valid'
  }))
]

export default syntaxAPI
