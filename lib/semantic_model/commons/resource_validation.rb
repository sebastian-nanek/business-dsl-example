module SemanticModel::Commons::ResourceValidation
  extend ActiveSupport::Concern

  OBJECT_ATTRIBUTES = [ :validation_type, :validation_param, :resource_attribute, :resource ]
  VALIDATION_TYPES = [ 
    :presence, :uniqueness, :numericality, :integer, :format, :length, 
    :equality, :less_or_equal_to, :greater_or_equal_to, :less_than, 
    :greater_than, :shorter_than, :longer_than
  ]
  VALIDATION_MAPPINGS = {
    /a unique value/ => :uniqueness,
    /always present/ => :presence,
    /always a number/ => :numericality,
    /always an integer number/ => :integer,
    
    /always greater than (.*)/ => :greater_than,
    /always not greater than (.*)/ => :less_or_equal_to,
    /always not smaller than (.*)/ => :greater_or_equal_to,
    /always less than (.*)/ => :less_than,
    /equal to (.*)/ => :equality,
    /always (.*) characters long/ => :length,
    /always shorter than (.*) characters/ => :shorter_than,
    /always longer than (.*) characters/ => :longer_than,
    /always in format \/(.*)\// => :format,
  }

  included do
    OBJECT_ATTRIBUTES.each do |attr_name|
      attr_accessor attr_name
    end    
  end

  def initialize(validation_type, validation_value = true)
    raise SemanticModel::InvalidValidationType.new "Invalid type of validation: #{validation_type}" unless VALIDATION_TYPES.include?(validation_type.to_sym)
    @validation_type = validation_type
    @validation_param = validation_value
  end

  # returns mapped validation, i.e.
  #   { :presence => true }
  #   { :length => 3 }
  # raises an Exception if no valid mapping found
  def self.map_validation(validation_as_string)
    mapped_validation = VALIDATION_MAPPINGS.select do |expr, mapped|
      validation_as_string.match(expr)              
    end    
    expr = mapped_validation.keys.first
    val = mapped_validation.values.first  
    if expr.nil?
      raise SemanticModel::UnknownValidation.new "Unknown validation: #{validation_as_string}" 
    else
      data = validation_as_string.match(expr).to_a[1] 
      { val => data.nil? ? true : data }
    end
  end

  def name
    "validation-#{@validation_type}-#{@resource_attribute}"
  end
end