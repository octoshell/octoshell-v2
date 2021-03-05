module CloudComputing
  class Interface

    class << self

      def fors
        @fors ||= []
      end

      def define_for(hash)
        required_keys = %i[model human_model human_instance]

        raise 'no required keys' if hash.keys != required_keys

        fors << hash
      end

    end
  end
end
