# encoding: utf-8

# The built-in collection types are defined here.
module Type
  collection(:Array) do
    validate do |input|
      input.kind_of?(::Array)
    end
    cast do |input|
      Kernel::Array(input)
    end
  end

  collection(:Hash) do
    validate do |input|
      input.kind_of?(::Hash)
    end
    cast do |input|
      if Kernel.respond_to?(:Hash)
        Kernel::Hash(input)
      else
        ::Hash[input]
      end
    end
  end

  collection(:Set) do
    require 'set'
    validate do |input|
      input.kind_of?(::Set)
    end
    cast do |input|
      ::Set.new(input)
    end
  end
end
