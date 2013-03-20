class SemanticModel::Stubs::Resource < SemanticModel::Stubs::Base
  include SemanticModel::Commons::Resource

  def destubize!
    resource = SemanticModel::Elements::Resource.new(@name)
    OBJECT_ATTRIBUTES.each do |attr|
      resource.send("#{attr}=".to_sym, self.instance_variable_get("@#{attr}")) 
    end
    resource
  end
end