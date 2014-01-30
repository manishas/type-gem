# Type

`Type` is a ruby library for type validation and type casting. It allows you to
have guarantees on data structures, and is exceptionally useful for working with
external APIs that blow up opaquely on type errors.

See [the Changelog](CHANGELOG.md) for version history.

## Installation

Add this line to your application's Gemfile:

    gem 'type'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install type

## Basic API

`Type::Definition`s respond to two public methods: `#cast!` and `valid?`, each
of which take a single argument and either cast or validate the given object.
For convenience, named type definitions have global aliases defined on `Type`:

~~~ ruby
# For example, `Type::Int32`, which is a built-in `Type::Definition`
Type::Int32?(input) # alias for Type::Int32.valid?(input)
Type::Int32!(input) # alias for Type::Int32.cast!(input)
~~~

## Usage

`Type` comes with a variety of built-in type defintions, which can be used for
validation or casting.

### Scalar Type Definitions:

The most basic type definitions are scalar

~~~ ruby
# Validating
Type::Int32?(1)
# => true
Type::Int32?(8_589_934_592) # out of Int32 range
# => false
Type::Int32?(3.14)
# => false
Type::Int32?('three')
# => false

# Casting
Type::Int32!(1)
# => 1
Type::Int32!(1<<33)
Type::CastError: Could not cast 8589934592(Fixnum) with Type::Int32
Type::Int32!(3.14)
# => 3
Type::Int32!('three')
#! Type::CastError: Could not cast "three"(String) with Type::Int32
~~~

The complete list of built-in scalar type definitions is:

~~~ ruby
Type::Integer # {x∈ℤ}
Type::Int32   # {x∈ℤ|[-2^31,2^31)}
Type::Int64   # {x∈ℤ|[-2^63,2^63)}
Type::UInt32  # {x∈ℕ|[0,2^32)}
Type::UInt64  # {x∈ℕ|[0,2^64)}
Type::Float   # {x∈ℝ,+∞,-∞}
Type::Float32 # {x∈ℝ}
Type::Float64 # {x∈ℝ}
Type::Boolean # {true,false}
Type::String  # any string
~~~

### Nilable Type Definitions:

Any `Type::Definition` can be declared nilable -- that is, it will report `nil`
as a valid value, and will ignore `nil` when casting.

~~~ ruby
# Validating
Type::Int32.valid?(nil)
# => false
Type::Int32.nilable.valid?(nil)
# => true

# Casting
Type::Int32.cast!(nil)
#! Type::CastError: Could not cast nil(NilClass) with Type::Int32
Type::Int32.nilable.cast!(nil)
# => nil
~~~

### Collection Type Definitions:

`Type` also comes with built-in, named definitions for `Array`, `Set`, and
`Hash` collections, which are available in the same manner:

~~~ ruby
# Validating
Type::Array?([1,2,3])
# => true
Type::Hash?({'foo'=>'bar'})
# => true
Type::Set?([1,2,3])
# => false
Type::Set?(Set.new([1,2,3]))
# => true

# Casting
Type::Array!([1,2,3])
# => [1,2,3]
Type::Hash!([['foo','bar']])
# => {'foo'=>'bar'}
Type::Set!([1,2,3])
# => <Set: {1, 2, 3}>
Type::Set!('foo')
#! Type::CastError: Could not cast "foo"(String) with Type::Set
~~~

The complete list of built-in collection type definitions is:

~~~ ruby
Type::Array
Type::Set
Type::Hash
~~~

### Constrained Collection Type Definitions:

The real power of type-casting collections is when their contents can also be
constrained:

~~~ ruby
# Validating:
# specify any Type::Definition, or the name of a globally-registered one:
Type::Array.of(Type::Int32).valid?([12, 13])
# => true
Type::Array.of(:Int32).valid?(['12', '13'])
# => false
Type::Array.of(:Int32).valid?(['three','two'])
# => false
Type::Hash.of(:String => :Int64).valid?({'id'=>'1234567890'})
# => false
Type::Hash.of(:String => :Int64).valid?({'id'=>1234567890})
# => true

# Casting:
Type::Array.of(:Int32).cast!([12, 13])
# => [12, 13]
Type::Array.of(:Int32).cast!(['12', '13'])
# => [12, 13]
Type::Array.of(:Int32).cast!(['three','two'])
#! Type::CastError: Could not cast ["three", "two"](Array) with Type::Array(Int32),
#!                  caused by <Type::CastError: Could not cast "three"(String) with Type::Int32>
Type::Hash.of(:String => :Int64).cast!({'id'=>'1234567890'})
# => {'id'=>1234567890}
Type::Hash.of(:String => :Int64).cast!({'id'=>1234567890})
# => {'id'=>1234567890}
~~~

### Nilable Constrained Collection Type Definitions

The contents of your constrained collections can also be nilable:

~~~ ruby
# Validating:
Type::Array.of(Type::Int32.nilable).valid?([nil, 3])
# => true
Type::Array.of(:Int32?).valid?([nil,4])
# => true

# Casting
Type::Array.of(Type::Int32.nilable).cast!([nil, '3'])
# => [nil, 3]
Type::Array.of(:Int32?).cast!([nil,4])
# => [nil, 4]
~~~

## Advanced Usage

### Custom Type Defintions

~~~ ruby
my_int32 = Type.scalar do
  int32_range = (-(1 << 31) ... (1 << 31))
  validate do |input|
    input.kind_of?(Integer) && int32_range.include?(input)
  end
  cast do |input|
    Kernel::Integer(input)
  end
end

my_int32.valid?('100') # => false
my_int32.valid?(100) # => true
my_int32.cast!(1<<10) # => 1024
my_int32.cast!("100") # => 100


simple_int32 = Type.scalar.from(Integer) do
  int32_range = (-(1 << 31) ... (1 << 31))
  validate do |input|
    int32_range.include?(input)
  end
end

simple_int32.valid?('100') # => false
simple_int32.valid?(100) # => true
simple_int32.cast!(1<<10) # => 1024
simple_int32.cast!("100") # => 100

Type.scalar(:OddInt).from(:Integer) do
  validate(&:odd?)
  cast do |input|
    input.even? ? input + 1 : input
  end
end

Type::OddInt?(4)
# => false
Type::OddInt!(4)
# => 5
~~~

If you find that you're using one or more custom type definitions on a regular
basis, please consider contributing them.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
