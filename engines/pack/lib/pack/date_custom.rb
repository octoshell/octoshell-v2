# class AmericanDate < ::Date
#   def to_s(_input = nil)
#     to_formatted_s(:american)
#   end
# end
#
# class AmericanDateType < ActiveRecord::Type::Date
#   def type
#   	:date
#   end
#
#   def klass
#   	::AmericanDate
#   end
#
#   def fallback_string_to_date(string)
#     begin
#       date=Date.strptime string,Date::DATE_FORMATS[:american]
#       AmericanDate.new(date.year ,date.month, date.day)
#     rescue
#       nil
#     end
#   end
#
#   def new_date(year, mon, mday)
#     if year && year != 0
#       ::AmericanDate.new(year, mon, mday) rescue nil
#     end
#   end
#
#   def type_cast_for_database(value)
#     if value.is_a? AmericanDate
#       value.to_default_s
#     else
#       nil
#     end
#   end
# end
#
# module CustomDateProccess
#   extend ActiveSupport::Concern
#   module ClassMethods
#     def american_date_proccess
#       columns.select {|elem| elem.type == :date}.each do |elem|
#       	attribute elem.name, AmericanDateType.new
#     	end
#     end
#   end
# end
# ActiveRecord::Base.include CustomDateProccess
