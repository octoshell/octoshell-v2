module Reports
	module ModelsList
		if Rails.env.production?
			def self.to_a
				@@to_a ||= load
			end

			def self.to_a_labels
				@@to_a_labels ||= to_a.map { |m| "#{m}|#{eval(m).model_name.human}"}
			end
		else
			def self.to_a
				load
			end

			def self.to_a_labels
				to_a.map { |m| "#{m}|#{eval(m).model_name.human}"}
			end
		end
		def self.load
			res = []
			Rails::Engine.subclasses.map do |r|
				mod_name = eval(r.name.split(/::/).first)
				res += mod_name.constants.select do |c|
					cl = eval("#{mod_name}::#{c}")
					cl.is_a?(Class) && cl < ActiveRecord::Base
				end.map{ |c| "#{mod_name}::#{c}" }
			end
			res += Module.constants.select do |c|
				cl = eval("#{c}")
				cl.is_a?(Class) && cl < ActiveRecord::Base
			end.map(&:to_s)
			res.sort
		end
	end
end
