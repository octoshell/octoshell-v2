module Octoface
  module Usage
    def octo_use(name, role, const)
      define_singleton_method("#{name}_to_s") do
        Octoface.mod_class_string(role, const)
      end
      define_singleton_method(name) do
        eval(Octoface.mod_class_string(role, const))
      end

      define_method("#{name}_to_s") do
        Octoface.mod_class_string(role, const)
      end
      define_method(name) do
        eval(Octoface.mod_class_string(role, const))
      end

      if self <= ApplicationController
        helper_method name
        helper_method "#{name}_to_s"
      end
    end
  end
  Class.include(Usage)
end
