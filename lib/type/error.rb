# encoding: utf-8

module Type
  # An Error class for exceptions raised while validating or casting
  class Error < ::TypeError
    def initialize(input, type_definition)
      @input = input
      @type_definition = type_definition
      @cause = $! # aka $ERROR_INFO
    end

    def to_s
      "<#{self.class.name}: #{message}#{caused_by_clause}>"
    end

    attr_reader :input, :type_definition, :cause

    private

    def caused_by_clause
      return '' unless @cause
      ", caused by #{@cause}"
    end
  end

  # Type::CastError is the raised class of Type::Definition#cast!
  class CastError < Error
    def message
      "Could not cast #{input.inspect} with #{type_definition}."
    end
  end

  # Type::ValidationError is raised internally in Type::Definition#cast!
  # when, after casting, an element fails to validate.
  # @api private
  class ValidationError < Error
    def message
      "#{input.inspect} is not valid #{type_definition}."
    end
  end
end
