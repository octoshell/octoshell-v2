module Octoface
  class OctoConfig
    def initialize(mod, &block)
      @mod = mod
      self.class.mods << @mod
      self.class.instances << self
      instance_eval &block
    end

    def add(name, obj)
      self.class.mod_methods[name] = obj
    end

    def self.mods
      @mods ||= []
    end

    def self.mod_methods
      @mod_methods ||= {}
    end

    def self.instances
      @instances ||= []
    end

    def self.finalize!
      mods.each do |mod|
        mod_methods.each do |key, value|
          mod.define_singleton_method(key) { value }
        end
      end
    end


  end
end
