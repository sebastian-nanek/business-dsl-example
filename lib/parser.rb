$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), './' ) )

module Parser
  begin :constants
    COMMENT_REGEXP = /^#.*/
    EXTERNAL_FILE_REGEXP = /This (sub)?section is defined in document "(.*)"\./
    MULTILINE_CONTINUATION_MARKER = /^- /
  end

  begin :exceptions
    class EmptyCode < Exception; end                  # String with code was either nil or empty
    class SemanticModelNotProvided < Exception; end   # Parser must be initialized with SemanticModel
    class NoMatchingRuleProvided < Exception; end     # empty callback code on initlaization

    class NoMatchingRuleFound < Exception; end        # input code has no matches in current SemanticModel
    class IncludedFileNotFound < Exception; end       # external file cannot be included - has not been found
    
    class ParserError < Exception; end                # other error
  end

  autoload :Base, 'parser/base'
  autoload :BaseRule, 'parser/base_rule'
  autoload :Rule, 'parser/rule'
  autoload :MultilineRule, 'parser/multiline_rule'
  autoload :RuleMatcher, 'parser/rule_matcher'
end