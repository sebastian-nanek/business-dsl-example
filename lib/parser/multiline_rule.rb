class Parser::MultilineRule < Parser::BaseRule
  begin :attribute
    attr_accessor :multiline_expression
  end

  def initialize(expr, multiline_expr = nil, opts = {}, &block)    
    raise Parser::NoMatchingRuleProvided.new("Rule must have matching rule Regexp provided.") unless expr.kind_of?(Regexp)
    raise Parser::NoMatchingRuleProvided.new("Rule must have matching rule subdefinition Regexp provided.") unless multiline_expr.kind_of?(Regexp)
    #raise Parser::EmptyCode.new("Rule must have production code.") if block.nil?
    @expression = expr
    @production_code = block
    @multiline_expression = multiline_expr    
  end

  # calls rule code block for every line of input string
  def parse(code_line, data_lines_array = nil)
    data_array = []
    matched_data = code_line.match(@expression).to_a
    unless data_lines_array.nil?
      matched_subobjects = data_lines_array.collect do |data_line|
        data_line.match(@multiline_expression).to_a unless @multiline_expression.nil?
      end
    end
    [ @production_code.call(matched_data, matched_subobjects) ]
  end


  # maps multiline data into an Array, using multiline expression
  def map_multiline_data(data_as_string)    
    data_as_string.each_line.collect do |row|
      row.match(@multiline_expression) do |matched_data|
        str, *values = *matched_data
        values
      end
    end
  end

  def multiline?
    true
  end
end