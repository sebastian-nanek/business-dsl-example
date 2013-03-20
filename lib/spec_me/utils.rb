module SpecMe::Utils
  # pretty printing array's content
  def self.inspect_array(arr)
    arr.map(&:to_s).join(", ")
  end

  # check if lowest level class anmes match
  # i.e. matching classes - Namespace::Dummy Module::Dummy will match
  def self.lowest_level_classes_match(obj1, obj2)
    obj.lowest_level_class_name(obj1.class) == obj.lowest_level_class_name(obj2.class) 
  end

  # return the name of deepest class in namespace hierarachy
  # i.e for SemanticModel::DummySpace::FooModule::SpaceClass will return SpaceClass
  def self.lowest_level_class_name(klass)
    klass.to_s.split("::").last
  end
end
