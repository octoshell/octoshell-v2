module Support
  class Interface
    def self.ticket_field(args)
      ModelField.new(args)
      # puts t.inspect
      # puts t.class
      # puts query.inspect
      #
      # puts args.inspect
    end
  end
end
