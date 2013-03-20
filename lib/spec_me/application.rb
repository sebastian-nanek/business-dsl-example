class SpecMe::Application  
  include ActiveSupport::Configurable

  begin :attributes
    attr_accessor :semantic_model
    attr_accessor :parser
    attr_accessor :template
  end

  # load application objects, data and then initialize them
  def self.initialize!    
    read_command_lines!
    print_initial_message!
    load_semantic_model!
    load_parser_with_rules!
  end

  ## parse a file with specification
  # and build model data from it
  #  :args: file_name
  def self.parse_spec!(file_name)
    code_as_string = File.open(file_name, 'r').read.to_s
    @parser.parse_data(code_as_string)
    #puts @parser.inspect
    #puts @semantic_model.inspect

  end

  def self.generate_application!
    raise SpecMe::RuntimeException.new "SemanticModel not build" if @semantic_model.empty?
    template_class = load_template!
    @template = template_class.new(@semantic_model, config.output_application_name, config.output_dir, config.template_dir)
    @template.build!
  end

  private
  def self.print_initial_message!
    puts "SpecMe v.1.0."
    puts "  "
    puts "Application name: #{config.output_application_name}"
    puts "Source file: #{config.spec_file}"
    puts "Template directory: #{config.template_dir}"
    puts "Target directory: #{config.output_dir}"
  end

  def self.load_semantic_model!
    @semantic_model = SemanticModel::Base.new  
  end

  def self.load_parser_with_rules!
    @parser = Parser::Base.new(@semantic_model)
  end

  def self.read_command_lines!
    args = {}
    ARGV.each { |arg| k, v = arg.split("=", 2); args[k] = v }

    config.output_application_name = args["NAME"]
    config.spec_file = args["FILE"]
    config.output_dir = args["OUTPUT"]
    config.template_dir = args["TEMPLATE"] || "default"    
  end

  # loads template manifest file
  # and subsequently -- loads all of its entries
  def self.load_template!    
    file_name = Dir.entries(config.template_dir).find { |fname| fname.match(/_template\.rb$/)}
    require config.template_dir + "/" + file_name
    file_name.gsub(".rb", "").camelize.constantize
  end
end