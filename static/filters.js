var jadefilters;

jadefilters = module.exports = {};

jadefilters.php = function(block) {
  return "<?php " + block + " ?>";
};

jadefilters.compiler = function(jade, data) {
  jade.Lexer.prototype.code = function() {
    var captures, flags, tok;
    captures = void 0;
    if (captures = /^(!?=|-)[ \t]*([^\n]+)/.exec(this.input)) {
      this.consume(captures[0].length);
      flags = captures[1];
      captures[1] = captures[2];
      tok = this.tok("code", captures[1]);
      tok.escape = flags.charAt(0) === "=";
      tok.buffer = flags.charAt(0) === "=" || flags.charAt(1) === "=";
      return tok;
    }
  };
  jade.Compiler.prototype.visitCode = function(code) {
    var val;
    val = code.val;
    if (code.buffer) {
      if (code.escape) {
        val = "htmlspecialchars(" + val + ", ENT_QUOTES, 'UTF-8')";
      }
      val = "echo " + val + ";";
    }
    this.buffer("<?php " + val + " ?>");
    if (code.block) {
      if (!code.buffer) {
        this.buf.push("{");
      }
      this.visit(code.block);
      if (!code.buffer) {
        this.buf.push("}");
      }
    }
  };
};

//# sourceMappingURL=filters.js.map
