module Support
  class Interface
    def self.ticket_field(t:, query:, **args)
      puts t.inspect
      puts t.class
      puts query.inspect

      puts args.inspect
    end
  end
end
