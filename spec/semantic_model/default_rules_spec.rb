require 'spec_helper'

describe SemanticModel::DefaultRules do
  subject { SemanticModel::DefaultRules }

  it "builds default rule set" do
    subject.rules.should_not be_empty
  end
  it "has section and subsection void rules" do
    rule = subject.section_rule
    rule.matches?('1. Section "Long Time Ago In Faraway Galaxy"').should be_true
    rule.parse('1. Section "Long Time Ago In Faraway Galaxy"').should == []
    rule = subject.subsection_rule
    rule.matches?('1.2. Subsection "Long Time Ago In Faraway Galaxy"').should be_true
    rule.parse('4.3. Subsection "Long Time Ago In Faraway Galaxy"').should == []
  end

  it "has resource rule" do
    rule = subject.resource_rule
    rule.matches?('System stores resource "Invoice".').should be_true
    built_object = rule.parse('System stores resource "Invoice".')
    built_object.length.should == 1
    built_object.first.should be_a_kind_of(SemanticModel::Elements::Resource)
    built_object.first.name.should == "Invoice"
  end

  it "has report rule" do
    rule = subject.report_rule
    rule.matches?('System presents "Unpaid invoices" report.').should be_true
    built_object = rule.parse('System presents "Unpaid invoices" report.')
    built_object.length.should == 1
    built_object.first.should be_a_kind_of(SemanticModel::Elements::Report)
    built_object.first.name.should == "Unpaid invoices"
  end

  it "has role rule" do
    rule = subject.role_rule
    rule.matches?('User can be assigned to "Admin" role.').should be_true
    built_object = rule.parse('User can be assigned to "Accountant" role.')
    built_object.length.should == 1
    built_object.first.should be_a_kind_of(SemanticModel::Elements::Role)
    built_object.first.name.should == "Accountant"
  end

  it "has resource role with a list of its fields" do
    spec_sample = [
      "System stores resource \"Invoice\" that contains following fields:",
      "- text field \"ident\"",
      "- date field \"issue_date\"",
      "- number field \"issue_date\"",
      "- floating point number field \"issue_date\""
    ]

    rule = subject.multiline_resource_rule
    rule.matches?(spec_sample.first).should be_true
    built_object = rule.parse(spec_sample.first, spec_sample[1..-1])

    built_object.length.should == 1
    built_object.first.should be_a_kind_of(SemanticModel::Elements::Resource)
    built_object.first.name.should == "Invoice"
    built_object.first.record_fields.length.should == 4
    built_object.first.record_fields.first.should be_a_kind_of(SemanticModel::Elements::ResourceField)
    built_object.first.record_fields.first.datatype.should == :text
  end

  it "can describe resource access rights" do
    spec_sample = [
      "Role \"Salesman\" allows user to:",
      "- list, create and change \"Company\" resource",
      "- create \"Invoice\" resource",
      "- list \"Customer\" resource",
    ]

    rule = subject.role_access_rights_rule
    rule.matches?(spec_sample.first).should be_true
    built_object = rule.parse(spec_sample.first, spec_sample[1..-1])

    built_object.length.should == 1
    built_object.first.should be_a_kind_of(SemanticModel::Stubs::Role)
    built_object.first.name.should == "Salesman"
    built_object.first.access_rules.length.should == 3
    first_rule = built_object.first.access_rules.first
    first_rule.resource.should be_a_kind_of(SemanticModel::Stubs::Resource)
    first_rule.resource.name.should == "Company"
    first_rule.role.should be_a_kind_of(SemanticModel::Stubs::Role)
    first_rule.role.name.should == "Salesman"
    first_rule.should be_a_kind_of(SemanticModel::Elements::AccessRule)
    first_rule.can_list.should be_true
    first_rule.can_create.should be_true
    first_rule.can_change.should be_true
  end

  it "can describe one to one relation" do
    spec_sample = "Resource \"Invoice\" has one \"Invoice Entry\" resource."

    rule = subject.one_to_one_relation_rule
    rule.matches?(spec_sample).should be_true
    built_object = rule.parse(spec_sample).first

    built_object.should be_a_kind_of(SemanticModel::Elements::ResourceRelation)
    built_object.relation_type.should == :one_to_one
    built_object.source.should be_a_kind_of(SemanticModel::Stubs::Resource)
    built_object.target.should be_a_kind_of(SemanticModel::Stubs::Resource)
    built_object.source.name.should == "Invoice"
    built_object.target.name.should == "Invoice Entry"
  end
  it "can describe one to many relation" do
    spec_sample = "Resource \"Invoice\" has one or more \"Invoice Entry\" resources."

    rule = subject.one_to_many_relation_rule
    rule.matches?(spec_sample).should be_true
    built_object = rule.parse(spec_sample).first

    built_object.should be_a_kind_of(SemanticModel::Elements::ResourceRelation)
    built_object.relation_type.should == :one_to_many
    built_object.source.should be_a_kind_of(SemanticModel::Stubs::Resource)
    built_object.target.should be_a_kind_of(SemanticModel::Stubs::Resource)
    built_object.source.name.should == "Invoice"
    built_object.target.name.should == "Invoice Entry"
  end

  it "can describe many to many relation" do
    spec_sample = "Resource \"Invoice\" can be assigned to many \"Invoice Entry\" resources."

    rule = subject.many_to_many_relation_rule
    rule.matches?(spec_sample).should be_true
    built_object = rule.parse(spec_sample).first

    built_object.should be_a_kind_of(SemanticModel::Elements::ResourceRelation)
    built_object.relation_type.should == :many_to_many
    built_object.source.should be_a_kind_of(SemanticModel::Stubs::Resource)
    built_object.target.should be_a_kind_of(SemanticModel::Stubs::Resource)
    built_object.source.name.should == "Invoice"
    built_object.target.name.should == "Invoice Entry"
  end

  it "can descibe state machines" do
    spec_sample = [
      "Resource \"Invoice\" can have one of following states: \"pending\", \"temporary\", \"confirmed\" and \"canceled\" and allows following transitions between them:", 
      "- from temporary to pending",
      "- from pending to canceled",
      "- from pending to confirmed"
    ]

    rule = subject.state_machine_rule
    rule.matches?(spec_sample.first).should be_true
    built_object = rule.parse(spec_sample.first, spec_sample[1..-1]).first
    built_object.should be_a_kind_of(SemanticModel::Stubs::Resource)
    built_object.name.should == "Invoice"
    built_object.state_machine.should be_a_kind_of(SemanticModel::Elements::StateMachine)
    built_object.state_machine.states.should == ["pending", "temporary", "confirmed", "canceled"]
    built_object.state_machine.transitions.first.should be_a_kind_of(SemanticModel::Elements::StateMachineTransition)
    built_object.state_machine.transitions.first.source.should == "temporary"
    built_object.state_machine.transitions.first.target.should == "pending"
    built_object.state_machine.transitions.length.should == 3

  end

  it "can describe one line validations (both parameterized and not)" do
    spec_sample = 
      'Field "author" of resource "Book" is always present.'
    rule = subject.one_line_validation_rule
    rule.matches?(spec_sample).should be_true
    built_object = rule.parse(spec_sample).first
      
    built_object.should be_a_kind_of(SemanticModel::Stubs::Resource)
    built_object.validations.length.should == 1
    built_object.validations.first.should be_a_kind_of(SemanticModel::Elements::ResourceValidation)
    built_object.validations.first.validation_type.should == :presence
    built_object.validations.first.validation_param.should == true

    spec_sample = 
      'Field "volumens" of resource "Book" is always equal to 2.'
    built_object = rule.parse(spec_sample).first
    built_object.validations.first.validation_type.should == :equality
    built_object.validations.first.validation_param.should == "2"
  end

  it "can describe multiline validations (both parameterized and not)" do
    spec_sample = [    
      'Field "author" of resource "Book" is:',
      '- always greater than 42',
      '- a unique value',
      '- always an integer number'
    ]
    rule = subject.multiline_validation_rule
    rule.matches?(spec_sample.first).should be_true
    built_object = rule.parse(spec_sample.first, spec_sample[1..-1]).first
      
    built_object.should be_a_kind_of(SemanticModel::Stubs::Resource)
    built_object.validations.length.should == 3
    built_object.validations.first.should be_a_kind_of(SemanticModel::Elements::ResourceValidation)
    built_object.validations.first.validation_type.should == :greater_than
    built_object.validations.first.validation_param.should == "42"
  end

  it "can describe fields that report can be filtered by" do
    spec_sample = 'Report "Unpaid invoices" can be filtered by following fields: "amount", "issue_date" and "description".'
    rule = subject.report_filters_rule
    rule.matches?(spec_sample).should be_true
    built_object = rule.parse(spec_sample).first
    built_object.should be_a_kind_of(SemanticModel::Stubs::Report)
    built_object.filtered_fields.should == [ "amount", "description", "issue_date" ]
  end

  it "can describe report source and its criterias" do
    spec_sample = [
      'System presents report "Eco old books", which is based on the resource "Book" and shows records that:',
      '- field "author" is equal to "Umberto Eco"',
      '- field "issue year" is less than "1989"',
      '- field "issue year" is greater than "1973"'
    ]
    rule = subject.report_source_rule
    rule.matches?(spec_sample.first).should be_true
    built_object = rule.parse(spec_sample.first, spec_sample[1..-1]).first
    built_object.should be_a_kind_of(SemanticModel::Stubs::Report)
    built_object.name.should == "Eco old books"
    built_object.criteria.keys.length.should == 2
    built_object.criteria.should be_a_kind_of(Hash)
    built_object.criteria["author"].should == { :equal => "Umberto Eco" }
    built_object.criteria["issue year"].should == { :lower => "1989", :greater => "1973" }
  end
end