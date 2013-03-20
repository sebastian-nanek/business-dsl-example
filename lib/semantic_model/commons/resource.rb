module SemanticModel::Commons::Resource
  extend ActiveSupport::Concern

  OBJECT_ATTRIBUTES = [ :record_fields, :state_machine, :relations, :access_rules, :validations ]

  included do
    OBJECT_ATTRIBUTES.each do |attr_name|
      attr_accessor attr_name
    end    
  end

  def merge_possible?(stub)
    stub.kind_of?(SemanticModel::Stubs::Resource)
  end
end