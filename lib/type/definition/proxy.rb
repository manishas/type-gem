# encoding: utf-8

module Type
  module Definition
    # @api private
    # The Proxy is an in-progress definition, a convenience object to support
    # the declaration syntax.
    class Proxy
      def initialize(name, klass)
        @name = name
        @klass = klass
      end

      # @see Type::Definition::generate() for usage
      def from(parent, &config)
        raise ArgumentError, 'Block Required!' unless block_given?

        Type[parent].tap do |resolved_parent|
          raise ArgumentError unless resolved_parent.kind_of?(@klass)
        end.refine(@name, &config)
      end
    end
  end
end
