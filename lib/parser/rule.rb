class Parser::Rule < Parser::BaseRule
  def initialize(expr, opts = {}, &block)    
    raise Parser::NoMatchingRuleProvided.new("Rule must have matching rule Regexp provided.") unless expr.kind_of?(Regexp)    
    @expression = expr
    @production_code = block
  end

  def multiline?
    false
  end
end