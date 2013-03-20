module SemanticModel::DefaultRules
  DEFAULT_RULES = [
    "section", "subsection", "resource", "resource_fields", "report", "role",
    "multiline_resource", "role_access_rights", "one_to_one_relation", 
    "one_to_many_relation", "many_to_many_relation", "state_machine", 
    "one_line_validation", "multiline_validation", "report_filters",  
    "report_source"
  ]

  # returns all default rules in the system, or builds them if they are not initialized yet
  def self.rules
    @default_rules || build_default_rules
  end

  # returns a number of rules available in the system
  def self.length
    rules.length
  end

  private
  # builds all rules to be inserted into SemanticModel
  def self.build_default_rules
    @default_rules ||= []

    DEFAULT_RULES.each do |rule_name|
      rule = send("#{rule_name}_rule".to_sym)
      @default_rules << rule
    end

    @default_rules
  end

  public
  def self.section_rule    
    SemanticModel::Base.build_rule(/^(.*) Section "(.*)"$/) do |name|    
    end
  end

  def self.subsection_rule
    SemanticModel::Base.build_rule(/^(.*) Subsection "(.*)"$/) do |name|    
    end
  end

  # resource building rules
  def self.resource_rule
    SemanticModel::Base.build_rule(/^System stores resource "(.*)"\.$/) do |name|
      SemanticModel::Elements::Resource.new(name.first)
    end
  end

  # resource building rules
  def self.multiline_resource_rule
    SemanticModel::Base.build_rule(/^System stores resource "(.*)" that contains following fields:$/, /^- (.*) field "(.*)"$/) do |name, fields_array|
      fields = fields_array.collect do |field|
        SemanticModel::Elements::ResourceField.new(field[2], field[1].to_sym)
      end
      resource = SemanticModel::Elements::Resource.new(name.last)
      resource.record_fields = fields
      resource
    end
  end

  def self.resource_fields_rule
    SemanticModel::Base.build_rule(/^Resource "(.*)" has following fields:$/, /(.*)/) do |matches|
      name = matches.first
      fields = matches.second.collect do |matched_row|  
        field_type, field_name = matched_row.first, matched_row.second
      end
      resource = SemanticModel::Stubs::Resource.new(name, data)
      resource.record_fields = fields
      resource
    end
  end

  # reports building rules
  def self.report_rule
    SemanticModel::Base.build_rule(/^System presents "(.*)" report\.$/) do |name|
      SemanticModel::Elements::Report.new(name.first)
    end
  end
  
  # designing access rules specs
  def self.role_rule
    SemanticModel::Base.build_rule(/^User can be assigned to "(.*)" role\.$/) do |name|
      SemanticModel::Elements::Role.new(name.first)
    end
  end

  def self.role_access_rights_rule
    SemanticModel::Base.build_rule(
      /^Role "(.*)" allows user to:$/, 
      /^- (.*) "(.*)" resources?$/ ) do |name, rules_array|
      role = SemanticModel::Stubs::Role.new(name.last.strip)      
      access_rules = rules_array.collect do |field|
        field_rights = field[1]
        resource_name = field[2]
        resource_stub = SemanticModel::Stubs::Resource.new(resource_name)
        
        rights_as_array = field_rights.to_s.downcase.split(/and|,/).map(&:strip)
        mapped_rights = SemanticModel::Commons::AccessRule.map_access_rights(rights_as_array)

        SemanticModel::Elements::AccessRule.new(resource_stub, {:role => role}.merge(mapped_rights))
      end
      role.access_rules = access_rules
      role
    end
  end

  def self.one_to_one_relation_rule
    SemanticModel::Base.build_rule(
      /^Resource "(.*)" has one "(.*)" resource.$/) do |resource_names|
      source_resource = SemanticModel::Stubs::Resource.new(resource_names[0])
      target_resource = SemanticModel::Stubs::Resource.new(resource_names[1])
      SemanticModel::Elements::ResourceRelation.new(:one_to_one, {:source => source_resource, :target => target_resource})
    end
  end

  def self.one_to_many_relation_rule
    SemanticModel::Base.build_rule(
      /^Resource "(.*)" has one or more "(.*)" resources.$/) do |resource_names|
      source_resource = SemanticModel::Stubs::Resource.new(resource_names[0])
      target_resource = SemanticModel::Stubs::Resource.new(resource_names[1])
      SemanticModel::Elements::ResourceRelation.new(:one_to_many, {:source => source_resource, :target => target_resource})
    end    
  end

  def self.many_to_many_relation_rule
    SemanticModel::Base.build_rule(
      /^Resource "(.*)" can be assigned to many "(.*)" resources.$/) do |resource_names|
      source_resource = SemanticModel::Stubs::Resource.new(resource_names[0])
      target_resource = SemanticModel::Stubs::Resource.new(resource_names[1])
      SemanticModel::Elements::ResourceRelation.new(:many_to_many, {:source => source_resource, :target => target_resource})
    end
  end

  # define a StateMachine for given object
  def self.state_machine_rule
    SemanticModel::Base.build_rule(
      /^Resource "(.*)" can have one of following states: (.*) and allows following transitions between them:$/, 
      /^- from (.*) to (.*)$/ ) do |name, transitions_array|
      resource = SemanticModel::Stubs::Resource.new(name.second.strip)      
      states = SemanticModel::Commons::StateMachine.map_states(name.last.strip)
      transitions = transitions_array.collect do |transition|
        source = transition[1]
        target = transition[2]
        SemanticModel::Elements::StateMachineTransition.new(resource, {:source => source, :target => target })
      end
      state_machine = SemanticModel::Elements::StateMachine.new(resource, { :states => states, :transitions => transitions })      
      resource.state_machine = state_machine
      resource
    end
  end

  # define one-line validation - one that has one rule and ends with a dot
  def self.one_line_validation_rule
    SemanticModel::Base.build_rule(
      /^Field "(.*)" of resource "(.*)" is (.*).$/) do |field_and_validation|      
      field_name = field_and_validation[0].strip      
      resource_name = field_and_validation[1].strip
      validation_as_string = field_and_validation[2]

      validation_rule = SemanticModel::Commons::ResourceValidation.map_validation(validation_as_string.strip)
      validation = SemanticModel::Elements::ResourceValidation.new(validation_rule.keys.first, validation_rule.values.first)

      resource = SemanticModel::Stubs::Resource.new(resource_name)
      resource.validations = [validation]
      resource
    end
  end

  # define multiline validations - one that has ends with a colon 
  # and is followed by a list beginning with dashes
  def self.multiline_validation_rule
    SemanticModel::Base.build_rule(
      /^Field "(.*)" of resource "(.*)" is:$/, /^- (.*)$/) do |field, validations|      
      field_name = field[0].strip      
      resource_name = field[1].strip
      rules = validations.collect do |validation_as_string|
        validation_rule = SemanticModel::Commons::ResourceValidation.map_validation(validation_as_string.last.strip)
        SemanticModel::Elements::ResourceValidation.new(validation_rule.keys.first, validation_rule.values.first)
      end
      resource = SemanticModel::Stubs::Resource.new(resource_name)
      resource.validations = rules
      resource
    end
  end


  # this rules defines a report with its source
  # and data building rules
  def self.report_source_rule
    SemanticModel::Base.build_rule(
      /^System presents report "(.*)", which is based on the resource "(.*)" and shows records that:$/, 
      /^- field "(.*)" is (.*) "(.*)"$/) do |field, source_rules|      
      report_name = field[1].strip      
      resource_name = field[2].strip     

      source_criteria = source_rules.collect do |criteria|        
        SemanticModel::Commons::Report.map_criteria(criteria[1..-1])
      end      
      merged_criteria = SemanticModel::Commons::Report.merge_criteria(source_criteria)

      report = SemanticModel::Stubs::Report.new(report_name)
      report.source = SemanticModel::Stubs::Resource.new(resource_name)
      report.criteria = merged_criteria
      report
    end
  end

  # this rule describes filters that are applicable for given report
  def self.report_filters_rule
    SemanticModel::Base.build_rule(
      /^Report "(.*)" can be filtered by following fields: (.*).$/) do |fields|      
      report_name = fields.first
      
      source_filters = SemanticModel::Commons::Report.map_filters(fields.last)      

      report = SemanticModel::Stubs::Report.new(report_name)      
      report.filtered_fields = source_filters
      report
    end
  end
end