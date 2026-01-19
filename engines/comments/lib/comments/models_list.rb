module Comments
  class ModelsList
    if Rails.env.production?
      def self.to_a
        @@to_a ||= load
      end

      def self.to_a_labels
        @@to_a_labels ||= to_a.map { |m| "#{m}|#{eval(m).model_name.human}" }
      end
    else
      def self.to_a
        load
      end

      def self.to_a_labels
        to_a.map { |m| "#{m}|#{eval(m).model_name.human}" }
      end
    end

    def self.load
      ApplicationRecord.subclasses.map(&:to_s).select do |name|
        m = name.split('::')&.first
        m.nil? || Octoface::OctoConfig.instances.values.map(&:mod).map(&:to_s).include?(m)
      end
      ApplicationRecord.subclasses.map(&:to_s)
    end

    def self.load_old
      res = []
      Rails::Engine.subclasses.each do |r|
        mod_name = eval(r.name.split(/::/).first)
        next unless Octoface::OctoConfig.instances.values.map(&:mod).include? mod_name

        res += mod_name.constants.select do |c|
          cl = eval("#{mod_name}::#{c}")
          cl.is_a?(Class) && cl < ActiveRecord::Base
        end.map { |c| "#{mod_name}::#{c}" }
      end
      res += Module.constants.select do |c|
        cl = eval("::#{c}")
        cl.is_a?(Class) && cl < ActiveRecord::Base
      end.map(&:to_s)
      res.sort
    end
  end
end
