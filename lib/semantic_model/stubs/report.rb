class SemanticModel::Stubs::Report < SemanticModel::Stubs::Base
  include SemanticModel::Commons::Report

  def destubize!
    resource = SemanticModel::Elements::Report.new(@name)
    OBJECT_ATTRIBUTES.each do |attr|
      resource.send("#{attr}=".to_sym, self.instance_variable_get("@#{attr}")) 
    end
    resource
  end
end