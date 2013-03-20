$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), './' ) )

require 'active_support/core_ext/module/delegation'

# SymbolTable represents all item textual identifier to item instance mappings in SpecMe DSL
class SymbolTable
  include Enumerable
  
  begin :attributes
    attr_accessor :table
  end

  begin :exceptions
    class InvalidOperation < Exception; end;
    class SymbolAlreadyUsed < Exception; end;
  end

  begin :delegations
    delegate :empty?, :to => :table, :allow_nil => true
    delegate :size, :to => :table, :allow_nil => true
    delegate :values, :to => :table, :allow_nil => true
  end

  def initialize
    @table = ActiveSupport::OrderedHash.new
  end

  # implementing Enumerable module
  def each(&block)
    @table.each &block
  end

  # checks if given unmapped key is known by systems
  def has_key?(key)
    @table.has_key?(map_key(key))
  end

  # maps given key according to rule applied to keys in that system
  def map_key(key)
    self.class.map_key(key)
  end

  # access given object from symbol table, providing any string that will map to its identifier
  def [](key)
    @table[map_key(key)]
  end

  # use #push or #operator<< instead
  def []=(key, obj)
    raise SymbolTable::InvalidOperation.new "Symbol table objects cannot be stored under arbitrary name. Instead, set valid SemanticModel::Resource name and use SemanticModel#push or SemanticModel#operator<<"
  end

  # pushes SemanticModel::Base descendant (i.e. Resource) into database
  # under key based on its name
  def <<(obj)
    #puts "---"
    #puts obj.inspect
    #puts "---"

    mapped_name = map_key(obj.name)

=begin
    puts "---------------"
    puts @table[mapped_name].inspect
    puts "---------------"
    puts obj.inspect
    puts "---------------"
=end

    if @table[mapped_name].nil?
      # empty key - just insert
      if obj.stub?
        @table[mapped_name] = obj.destubize!
      else
        @table[mapped_name] = obj
      end
    #elsif obj.kind_of?(@table[mapped_name].class) and @table[mapped_name].merge_possible?(obj)
    elsif @table[mapped_name].merge_possible?(obj)
      # not empty, but merge possible
      @table[mapped_name].merge_with(obj)
    else
      # not empty and cannot be merged
      raise SymbolTable::SymbolAlreadyUsed.new "Symbol '#{mapped_name}' is already used, and cannot be redefined."
    end
  end

  alias :push :<<

  # maps given string to a valid SymbolTable key by removing all unnecessary
  # spaces, changing spaces to dashes and downcasing all characters
  def self.map_key(key)
    key.downcase.squish.gsub(/\s/, "-")
  end
end