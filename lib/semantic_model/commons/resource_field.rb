module SemanticModel::Commons::ResourceField
  extend ActiveSupport::Concern

  OBJECT_ATTRIBUTES = [ :datatype ] #, :validations ]
  AVAILABLE_TYPES = [ :string, :text, :integer, :float, :currency, :date, :time, :state_machine, :enumeration ]
  DATATYPE_MAPPING = {
    "floating point number" => :float,
    "floating number" => :float,
    "float number" => :float,
    "long string" => :text,
    "long text" => :text,
    "number" => :integer,

  }


  included do
    OBJECT_ATTRIBUTES.each do |attr_name|
      attr_accessor attr_name
    end    
  end

  def initialize(name, datatype, options = {})
    @name = name
    datatype = map_datatype(datatype)
    if AVAILABLE_TYPES.include?(datatype.to_sym)
      @datatype = datatype
    else
      raise SemanticModel::InvalidFieldType.new "Invalid ResourceField type provided: #{datatype}. Available field types: #{SpecMe::Utils.inspect_array(AVAILABLE_TYPES)}"
    end    
    @data = options.with_indifferent_access[:data] || []
    @errors = {}
    @identifier = name.to_s.downcase.parameterize   

  end

  # map passed datatype string
  # into a real type (a kind of Symbol)
  # to allow using non-standard datatypes
  def map_datatype(type)
    type_as_string = type.to_s.strip.downcase
    if DATATYPE_MAPPING.keys.include?(type_as_string)
      DATATYPE_MAPPING[type_as_string].to_sym
    else
      type_as_string.to_sym
    end
  end
end