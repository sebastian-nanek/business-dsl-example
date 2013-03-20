class SemanticModel::Base
  include SemanticModel::DefiningRules

  begin :attributes
    attr_accessor :rules
    attr_accessor :roles
    attr_accessor :symbol_table
  end

  def initialize(opts = {})
    @reports = opts[:reports] || []
    @roles = opts[:roles] || []
    @rules = opts[:rules] || []
    @symbol_table = SymbolTable.new
  end

  # returns true if there are no custom rules and objects represented in the system
  def empty?
    @rules.empty? && @symbol_table.empty?
  end

  # access all rules known by this SemanticModel  
  def rules
    self.class.default_rules + @rules
  end

  # access class variable storing all available default rules
  def self.default_rules
    SemanticModel::DefaultRules.rules
  end

  # inserts given object or parse result into the SemanticModel
  def push(obj)
    if obj.kind_of?(Array)
      obj.each do |array_element|
        push(array_element)
      end
    elsif obj.kind_of?(SemanticModel::Elements::Base) or obj.kind_of?(SemanticModel::Stubs::Base)
      @symbol_table.push obj
    else
      raise SemanticModel::InvalidObject.new "I don't know how to deal with obj: #{obj.to_s}."
    end      
  end
end