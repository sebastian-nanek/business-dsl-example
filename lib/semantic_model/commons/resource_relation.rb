module SemanticModel::Commons::ResourceRelation
  extend ActiveSupport::Concern

  OBJECT_ATTRIBUTES = [ :relation_type, :source, :target ]
  RELATION_TYPES = [ :one_to_one, :one_to_many, :many_to_many ]

  included do
    OBJECT_ATTRIBUTES.each do |attr_name|
      attr_accessor attr_name
    end    
  end

  def initialize(relation_type, data = {})
    relation_type = relation_type.to_sym
    raise SemanticModel::UnknownRelation.new "Unknown relation type: #{relation_type}." unless RELATION_TYPES.include?(relation_type)
    @relation_type = relation_type

    data = data.with_indifferent_access
    OBJECT_ATTRIBUTES.each do |attr|
      var = "@#{attr}"
      unless instance_variable_defined?(var)
        instance_variable_set(var, data[attr])
      end
    end 
  end

  def name
    "relation-#{@relation_type}-#{@source.name}-#{@target.name}"
  end
end