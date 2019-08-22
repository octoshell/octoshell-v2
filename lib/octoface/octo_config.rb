module Octoface
  class OctoConfig
    attr_reader :abilities, :mod, :controller_abilities, :routes_block
    def initialize(mod, &block)
      @mod = mod
      @abilities = []
      @controller_abilities = []
      self.class.instances << self
      instance_eval &block
    end

    def add(name, &obj)
      self.class.mod_methods[name] = obj
    end

    #add_ability do
    # [:manage, :admin, '', 'superadmins']
    #end

    def add_ability(*args)
      @abilities << args
    end

    def add_controller_ability(*args)
      @controller_abilities << args
    end

    def add_routes(&block)
      @routes_block = block
    end

    def self.action_and_subject_by_path(path)
      mod = path.split('/').first
      inside_engine_path = path.split('/')[1..-1].join('/')
      found_instance = instances.detect do |instance|
        mod_string = instance.mod.to_s.underscore
        mod_string == mod
      end

      unless found_instance
        found_instance = instances.detect do |instance|
          mod_string = instance.mod.to_s.underscore
          mod_string == 'fake_main_app'
        end
        inside_engine_path = path
      end
      found_instance.controller_abilities.detect { |ab| ab[2..-1].include?(inside_engine_path)}[0..1]

    end

    # def self.mods
    #   @mods ||= []
    # end

    def self.mod_methods
      @mod_methods ||= {}
    end

    def self.instances
      @instances ||= []
    end

    def self.create_abilities!
      instances.each do |instance|
        instance.abilities.each do |a|
          Group.all.each do |g|
            Permission.where(action: a[0], subject_class: a[1], group_id: g.id).first_or_create do |ability|
              ability.available = a[2..-1].include?(g.name)
            end
          end
        end
      end
    end

    def self.forward_classes!
      instances.each do |instance|
        mod_methods.each do |key, value|
          instance.mod.define_singleton_method(key, &value)
        end
      end
    end

    def self.db_present?
      ::ActiveRecord::Base.connection_pool.with_connection(&:active?)
    rescue
      false
    end

    def self.finalize!
      if db_present?
        # create_abilities!
      end
      forward_classes!
      # Face::MyMenu.validate_keys!
    end


  end
end
