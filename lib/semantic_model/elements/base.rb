class SemanticModel::Elements::Base
  include SemanticModel::Commons::Base

  begin :attributes
    attr_accessor :errors
    attr_accessor :name    
    attr_accessor :data

    attr_reader :identifier
  end

  def initialize(name, options = {})
    @name = name
    @identifier = name.to_s.downcase.parameterize            
    @data = options.with_indifferent_access[:data] || []
    @errors = {}
  end

  def name=(nm)
    @name = nm
    @identifier = nm.downcase.parameterize
  end

  def valid?
    perform_validations
  end

  def merge_with(element_stub)
    merge_data(element_stub) # && valid? 
  end

  # to check if given object is a stub
  def stub?
    false
  end

  def self.possible_merge_classes
    [ 
      self,
      ("SemanticModel::Stubs::#{SpecMe::Utils.lowest_level_class_name(self.to_s)}").constantize
    ]
  end

  private
  def merge_data(stub)
    if stub.name != @name or !(self.class.possible_merge_classes.include?(stub.class))
      raise SemanticModel::ImpossibleMerge.new "Object names do not match" 
    end

    # merge data fields, without actually checking it
    if !stub.data.nil? and !stub.data.empty?            
     @data += stub.data
   end

    true
  end

  def perform_validations
    if @name.nil? or @name.empty?
      @errors[:name] ||= []
      @errors[:name] << "#{self.class.to_s} - field name is empty."
    end
    @errors.empty?
  end

end