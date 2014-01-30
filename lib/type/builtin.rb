# encoding: utf-8

# The built-in types are defined here.
module Type
  scalar(:Integer) do
    validate do |input|
      input.kind_of?(::Integer)
    end
    cast do |input|
      Kernel::Integer(input)
    end
  end

  scalar(:Int32).from(:Integer) do
    int32_range = (-(1 << 31) ... (1 << 31))
    validate do |input|
      int32_range.include?(input)
    end
  end

  scalar(:Int64).from(:Integer) do
    int64_range = (-(1 << 63) ... (1 << 63))
    validate do |input|
      int64_range.include?(input)
    end
  end

  scalar(:UInt32).from(:Integer) do
    int32_range = (0 ... (1 << 32))
    validate do |input|
      int32_range.include?(input)
    end
  end

  scalar(:UInt64).from(:Integer) do
    int64_range = (0 ... (1 << 64))
    validate do |input|
      int64_range.include?(input)
    end
  end

  scalar(:Float) do
    validate do |input|
      input.kind_of?(::Float)
    end
    cast do |input|
      Kernel::Float(input)
    end
  end

  scalar(:Float32).from(:Float) do
    validate do |input|
      input.finite?
    end
  end

  scalar(:Float64).from(:Float) do
    validate do |input|
      input.finite?
    end
  end

  scalar(:Boolean) do
    require 'set'
    booleans = Set.new([true, false])
    validate do |input|
      booleans.include?(input)
    end
    cast do |input|
      input ? true : false
    end
  end

  scalar(:String) do
    validate do |input|
      input.kind_of?(::String)
    end
    cast do |input|
      raise TypeError if input.nil?
      Kernel::String(input)
    end
  end

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
