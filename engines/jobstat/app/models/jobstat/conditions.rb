module Jobstat
  class Threshold
    attr_accessor :name, :description

    def initialize(name, description)
      @name = name
      @description = description
    end
  end

  class Rule
    attr_accessor :name, :description, :group, :priority, :suggestion, :text_recommendation, :module_recommendation

    def initialize(name, description, group, priority, suggestion, text_recommendation, module_recommendation)
      @name = name
      @description = description
      @group = group
      @priority = priority
      @suggestion = suggestion
      @text_recommendation = text_recommendation
      @module_recommendation = module_recommendation
    end
  end

  class Klass
    attr_accessor :name, :description, :group, :priority

    def initialize(name, description, group, priority)
      @name = name
      @description = description
      @group = group
      @priority = priority
    end
  end

  class Conditions
    attr_accessor :thresholds, :rules, :classes


    def initialize()
      @thresholds = {}
      @rules = {}
      @classes = {}

      loadThreshols
      loadRules
      loadClasses
    end

    def loadThreshols
      CSV.foreach("engines/jobstat/config/thresholds.csv") do |row|
        if row[1].to_i == 1
          @thresholds[row[0]] = Threshold.new(row[0], row[2])
        end
      end
    end

    def loadRules
      CSV.foreach("engines/jobstat/config/rules.csv") do |row|
        if row[1].to_i == 1
          @rules[row[0]] = Rule.new(row[0], row[2], row[5], row[6].to_i, row[9], row[10], row[11])
        end
      end
    end

    def loadClasses
      CSV.foreach("engines/jobstat/config/classes.csv") do |row|
        if row[1].to_i == 1
          @classes[row[0]] = Klass.new(row[0], row[2], row[5], row[6].to_i)
        end
      end
    end

    @@instance = Conditions.new

    def self.instance
      return @@instance
    end
  end
end
