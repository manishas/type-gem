# encoding: utf-8

module Type
  class << self
    # @see Definition::Scalar#generate
    def scalar(name = nil, &block)
      Definition::Scalar.generate(name, &block)
    end
  end

  module Definition
    # The Scalar Class is an implementation of Definition interface
    # that takes 100% of implementation from the base. This is
    # to differentiate it from Collection, which has additional
    # constraints.
    class Scalar
      include Definition
    end
  end
end
