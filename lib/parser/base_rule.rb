class Parser::BaseRule
  begin :attribute
    attr_accessor :expression
    attr_accessor :production_code  
  end

  def initialize(expr, multiline_expr = nil, opts = {}, &block)    
    raise NotImplementedError.new "This method is abstract - it shall be overriden in descending class"    
  end

  # calls rule code block for every line of input string
  def parse(input_code, data_as_string = "")
    data_array = []
    matched_data = input_code.match(@expression).to_a
    if matched_data.length > 1
      str, *values = *matched_data
      data_array << values
    end    
    data_array.collect { |data_row| @production_code.call(data_row) }.compact
  end

  # check if that rule applies for given string
  def matches?(input_code)
    !!(input_code.match(@expression))
  end

  # implemented in submodels - easily checking if matched rule is multiline 
  # (i.e. is followed by lines that begin with a dash sign)
  def multiline?
    raise NotImplementedError.new "This method is abstract - it shall be overriden in descending class"
  end
end