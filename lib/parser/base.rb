class Parser::Base
  attr_accessor :parse_rules
  attr_accessor :semantic_model

  def initialize(semantic_model)
    unless semantic_model.kind_of? SemanticModel::Base
      raise Parser::SemanticModelNotProvided.new("An instance of SemanticModel was not provided on Parser initialization") 
    end
    @parse_rules = []
    @semantic_model = semantic_model
    @parse_rules = @semantic_model.rules
  end

  def parse_data(code_as_string)
    raise Parser::EmptyCodeException "Code not provided." if code_as_string.nil? or code_as_string.empty?

    code_lines = preprocess_code(code_as_string)
    code_lines = remove_comments(code_lines)
    code_lines = load_external_files(code_lines)
    code_lines.flatten!


    rule = nil # to know rule identifier before getting into any loop iteration

    # because we need to keep state between iterations
    index = 0    
    while index < code_lines.length
      line = code_lines[index]
      if rule = find_matching_rule(line)
        begin
          if rule.multiline?          
            main_line = line
            sublines = []
            while line = code_lines[index+1] and multiline_continuation?(line)
              sublines << line
              index += 1
            end
            result = rule.parse(main_line, sublines)                
          else
            result = rule.parse(line)                
          end
          @semantic_model.push(result) unless result.nil?
        rescue Exception => e
          puts e.message
          puts e.backtrace
          raise Parser::ParserError.new("Error parsing file at line #{index + 1}: #{line}")
        end
      else
        raise Parser::NoMatchingRuleFound.new("Cannot match any rule for expression at line #{index + 1}: #{line}")
      end
      index += 1
    end
  end

  def find_matching_rule(code)
    @parse_rules.find do |rule|
       rule.matches?(code)
    end
  end

  # remove empty lines, strip the rest of them and convert result to an array
  def preprocess_code(code_string)
     code_string.lines.collect { |line| l = line.strip; l unless l.empty?}.compact
  end

  # load all files that are included in current spec
  def load_external_files(code_array)
    code_array.collect do |line|       
      match = line.match(Parser::EXTERNAL_FILE_REGEXP) 
      if match
        file_name = match.to_a.last
        begin 
          file = File.open(file_name, 'r')
          data = file.lines.to_a.join("\n")
          file.close
          data = preprocess_code(data)
          data = remove_comments(data)
          data = load_external_files(data)
          data
        rescue Exception => e
          raise Parser::IncludedFileNotFound.new "File not found: #{file_name} or other error."
        end
      else
        line
      end
    end
  end

  # remove all lines begining with "#" - comments
  def remove_comments(code_array)
    code_array.select { |line| !(line.match(Parser::COMMENT_REGEXP)) }
  end

  private
  def multiline_continuation?(line)
    !!(line.match(Parser::MULTILINE_CONTINUATION_MARKER))
  end

end