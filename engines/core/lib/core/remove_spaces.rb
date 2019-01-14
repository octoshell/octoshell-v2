module RemoveSpaces
  extend ActiveSupport::Concern
  module ClassMethods
    def remove_spaces(*args)
      before_validation do
        args.each do |arg|
          removed = send(arg).gsub(/\s{2,}/, ' ').gsub(/^\s+/, '').gsub(/\s+$/, '')
          send("#{arg}=", removed)
        end
      end
    end
  end
end
ActiveRecord::Base.include RemoveSpaces
