# encoding: utf-8

require 'type/version'
require 'type/error'
require 'type/definition'

# Type is a library for type-casting and type-validation
module Type
  class << self
    # @overload find(query)
    #   @param query [Type::Definition]
    # @overload find(query)
    #   @param query [String, Symbol]
    #     Find a named Type::Defintion. If the query ends with a ?,
    #     a nilable representation of the reolved type definition is returned.
    # @return [Type::Definition]
    def find(query)
      return query if query.kind_of?(Definition)

      query = String(query)
      nilable = query.end_with?('?') && query.slice!(-1)

      definition = const_get(query)
      (nilable ? definition.nilable : definition)
    end
    alias_method :[], :find

    # @api private
    # @param [Type::Definition]
    # @return [void]
    def register(definition)
      if (name = definition.name)
        const_set(name, definition)
        (class << self; self; end).instance_exec do
          define_method("#{name}!") { |x| definition.cast!(x) }
          define_method("#{name}?") { |x| definition.valid?(x) }
        end
      end
    end
  end

  # Required after, since they rely on the above methods.
  require 'type/builtin'
end
