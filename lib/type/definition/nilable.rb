# encoding: utf-8

module Type
  # Re-open Definition to add nilable methods
  module Definition
    # Return a nilable representation of this type definition
    # @return [Type::Definition::Nilable]
    def nilable
      Nilable.new(self)
    end

    # @return [False]
    def nilable?
      false
    end

    # Nilable Type::Definitions are the same as their non-nilable
    # counterparts with the following exceptions:
    # - a `nil` value is considered valid
    # - a `nil` value is returned without casting
    class Nilable
      include Definition
      def initialize(parent)
        super(nil, parent)
      end

      # Returns true if input is nil *or* the input is valid
      def valid?(input)
        input.nil? || super
      end

      # Casts the input unless it is nil
      def cast!(input)
        return nil if input.nil?
        super
      end

      # @return [True]
      def nilable?
        true
      end

      # @return [self]
      def nilable
        self
      end

      # @return [String]
      def to_s
        parent_name = @parent && @parent.name
        parent_name ? "Type::#{parent_name}(nilable)" : super
      end
    end
  end
end
