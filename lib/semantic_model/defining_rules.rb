module SemanticModel::DefiningRules
  extend ActiveSupport::Concern

  # define custom rules to be used in that semantic model
  def define_rule(expr, multiline_expr = nil, &block)
    if multiline_expr.nil?
      rule = Parser::Rule.new(expr, {}, &block)
    else
      rule = Parser::MultilineRule.new(expr, multiline_expr, {}, &block)
    end
    @rules << rule
  end

  module ClassMethods
    # define default/base rules in system available in all instances of SemanticModel
    def build_rule(expr, multiline_expr = nil, &block)
      data = { :default => true }
      if multiline_expr.nil?
        Parser::Rule.new(expr, data, &block)
      else
        Parser::MultilineRule.new(expr, multiline_expr, data, &block)
      end
    end
  end
end