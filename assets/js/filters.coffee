jadefilters = module.exports = {}

jadefilters.php = (block) ->
  return "<?php #{block} ?>"

jadefilters.compiler = (jade, data) ->
  # jade = require('jade')  unless jade

  # Precisa sobrescrever para retirar validação JS
  jade.Lexer::code = ->
    captures = undefined
    if captures = /^(!?=|-)[ \t]*([^\n]+)/.exec @input
      @consume captures[0].length
      flags = captures[1]
      captures[1] = captures[2]
      tok = @tok "code", captures[1]
      tok.escape = flags.charAt(0) is "="
      tok.buffer = flags.charAt(0) is "=" or flags.charAt(1) is "="

      # if (tok.buffer) assertExpression(captures[1])
      tok

  jade.Compiler::visitCode = (code) ->
    val = code.val
    if code.buffer
      val = "htmlspecialchars(#{val}, ENT_QUOTES, 'UTF-8')"  if code.escape
      val = "echo #{val};"
    @buffer "<?php #{val} ?>"
    if code.block
      @buf.push "{"  unless code.buffer
      @visit code.block
      @buf.push "}"  unless code.buffer
    return

  return