module SemanticModel::Commons::Role
  extend ActiveSupport::Concern

  OBJECT_ATTRIBUTES = [ :access_rules ]

  included do
    OBJECT_ATTRIBUTES.each do |attr_name|
      attr_accessor attr_name
    end    
  end
end