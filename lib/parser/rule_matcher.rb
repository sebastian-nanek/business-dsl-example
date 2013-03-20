class Parser::RuleMatcher
  attr_accessor :rules
  attr_accessor :semantic_model

  def initialize(rule_set, semantic_model)
    @rules = rule_set
  end

  def find_first_match(instr)
    @rules.find do |rule|
       rule.matches?(instr)
    end
  end

  def add_rule(rule)
    @rules << rule if rule.kind_of? SemanticModel::MatchingRule
  end
end
