module Pack

	module ZZZZ

  extend ActiveSupport::Concern

  # add your instance methods here
  def foo
     "foo"
  end

  # add your static(class) methods here
  class_methods do
    #E.g: Order.top_ten        
    def top_ten
      limit(10)
    end
  end
end

# include the extension 
ActiveRecord::Base.send(:include, ZZZZ)
end