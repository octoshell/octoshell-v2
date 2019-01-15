module Core
  class MergeError < StandardError
    attr_reader :message
    def initialize(message)
      @message = message
    end
  end
end
