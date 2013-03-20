module SemanticModel::Commons::Base
  extend ActiveSupport::Concern

  OBJECT_ATTRIBUTES = %w{data}

  included do    
    begin :attributes
      attr_accessor :fields
      attr_accessor :data
    end
  end

  # returns true if given stub or element can be merged into this object
  def merge_possible?(stub_or_element)
    false
  end

  # initializes object by assigning its name and cloning all data fields
  # important - if you need to change first paramter, i.e. to associated object
  # don't call super in child's constructor
  def initialize(name, data = {})
    @fields = data[:fields] || []
    data = data.with_indifferent_access
    const_get("OBJECT_ATTRIBUTES").each do |attr|
      instance_variable_set("@#{attr}", data[attr])
    end      
  end
end
