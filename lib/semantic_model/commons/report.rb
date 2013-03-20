module SemanticModel::Commons::Report
  extend ActiveSupport::Concern

  OBJECT_ATTRIBUTES = [ :source, :criteria, :filtered_fields ]
  CRITERIA_TYPES = [ :greater, :lower, :less_or_equal, :equal, :greater_or_equal ]
  CRITERIA_MAPPING = {
    "greater than" => :greater,
    "less than" => :lower,
    "equal to" => :equal,
    "less than or equal to" => :less_or_equal,
    "not greater than" => :less_or_equal,
    "not less than" => :greater_or_equal,
  }

  included do
    OBJECT_ATTRIBUTES.each do |attr_name|
      attr_accessor attr_name
    end    
  end

  # maps criteira from array of triples (name, type, value)
  # into proper validation hashes
  def self.map_criteria(criteria)
    field_name = criteria[0]
    criteria_type = map_criteria_type(criteria[1])
    criteria_value = criteria[2]
    { field_name => { criteria_type => criteria_value } }
  end

  # maps a list of fields into an array, i.e.
  # '"name", "publisher" and author"' ~~> ["name", "publisher", "author"]
  def self.map_filters(filters_as_string)
    filtered_fields = filters_as_string.split(/and|,/).map(&:strip).collect do |filtered_field|
      filtered_field.gsub('"', '')
    end
    filtered_fields.sort
  end

  # merges resource selection criteria hashes provided as an array
  # raises an Exception if no merge possible
  def self.merge_criteria(criteria_array)
    merged = {}
    criteria_array.each_with_index do |c, index|      
      field_key = c.keys.first
      criteria_key = c.values.first.keys.first
      value = c.values.first.values.first
      if !merged.has_key?(field_key)
        merged[field_key] = c[field_key]
      elsif merged.has_key?(field_key) and !(merged[field_key].has_key?(criteria_key))
        merged[field_key][criteria_key] = value
      else
        raise SemanticModel::ImpossibleReportCriteriaCombination.new "Impossible criteria merge (possible duplication) on line #{index+1} of criterias."
      end
    end
    merged
  end

  def merge_possible?(stub)
    stub.kind_of?(SemanticModel::Stubs::Report)
  end

  private
  def self.map_criteria_type(criteria_type)
    type = CRITERIA_MAPPING[criteria_type.downcase.strip]
    if type.nil?
      raise SemanticModel::UnknownReportCriteria.new "Unknown criteria: \"#{criteria_type}\" for report."
    else
      type
    end
  end
end