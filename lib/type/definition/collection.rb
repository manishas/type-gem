# encoding: utf-8

require 'type/definition/collection/constrained'

module Type
  class << self
    # see Definition::Collection#generate
    def collection(name = nil, &block)
      Definition::Collection.generate(name, &block)
    end
  end

  module Definition
    # Type::Definition::Collection validate and cast enumerables.
    # For a more interesting implementation, see the constrained
    # implementation of Type::Definition::Collection::Constrained
    class Collection
      include Definition

      def valid?(input, &block)
        return false unless input.kind_of?(Enumerable)
        super
      end

      def cast!(input, &block)
        raise CastError.new(input, self) unless input.kind_of?(Enumerable)
        super
      end
    end
  end
end
