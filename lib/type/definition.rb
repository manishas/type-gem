# encoding: utf-8

require 'type/definition/proxy'

module Type
  # Type::Definition is the interface for all type definitions.
  #
  # Standard implementations are:
  #   - Type::Definition::Scalar
  #   - Type::Definition::Collection
  # Modifier implementations are:
  #   - Type::Definition::Nilable, available as Type::Definition#nilable
  #
  module Definition
    module ClassMethods
      # @api protected
      #   Public APIs are Type::scalar and Type::collection
      # @overload generate(name, &block)
      #   The block is called in the context of the definition, and is expected
      #   to call one of `#validate` or `#cast` with appropriate blocks.
      #   @param name [Symbol, nil] (nil)
      #     Capital-letter symbol (e.g., `:Int32`) for which to register this
      #     definition globally.
      #   @return [Type::Definition]
      #   @example
      #   ~~~ ruby
      #     Type::scalar(:Integer) do
      #       validate do |input|
      #         input.kind_of?(::Integer)
      #       end
      #       cast do |input|
      #         Kernel::Integer(input)
      #       end
      #     end
      #   ~~~
      #
      # @overload generate(name)
      #   @param name [Symbol, nil] (nil)
      #     Capital-letter symbol (e.g., `:Int32`) for which to register this
      #     definition globally.
      #   @return [Type::Definition::Proxy]
      #     You are expected to call from(type_def, &block) to finish the
      #     definition
      # @return [Type::Definition, Type::Definition::Proxy]
      #   @example
      #   ~~~ ruby
      #     Type::scalar(:Int32).from(:Integer) do
      #       int32_range = (-1 << 31) ... (1 << 31)
      #       validate do |input|
      #         int32_range.include?(input)
      #       end
      #     end
      #   ~~~
      def generate(name = nil, &block)
        return new(name, &block) if block_given?
        Proxy.new(name, self)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    # Create a new Type::Definition
    #   You should never have to use Type::Definition#initialize directly;
    #   instead use Type::Definition::generate()
    #
    # @param name [Symbol] (nil)
    #   Capital-letter symbol (e.g., `:Int32`) for which to register this
    #   definition globally.
    #   If defining a `Type::Definition` with name `:FooBar`,
    #   the following are registerde:
    #     - `Type::FooBar`: a reference to the `Type::Definition`
    #     - `Type::FooBar()`: an alias to `Type::FooBar::cast!()`
    #     - `Type::FooBar?()`: an alias to `Type::FooBar::validate?()`
    # @param parent [Symbol, Type::Definition]
    #   A parent Type::Definition whose validation and casting is done *before*
    #   it is done in self. See the builtin Type::Int32 for an example.
    def initialize(name = nil, parent = nil, &block)
      @name = name && name.to_sym
      if parent
        @parent = Type.find(parent)
        validators.concat @parent.validators.dup
        castors.concat @parent.castors.dup
      end
      Type.register(self)
      instance_exec(&block) if block_given?
    end
    attr_reader :name

    # @param input [Object]
    # @return [Boolean]
    def valid?(input)
      validators.all? { |proc| proc[input] }
    rescue
      false
    end

    # @param input [Object]
    # @return [Object] the result of casting, guaranteed to be valid.
    # @raise [Type::CastError]
    def cast!(input)
      castors.reduce(input) do |intermediate, castor|
        castor[intermediate]
      end.tap do |output|
        raise ValidationError.new(output, self) unless valid?(output)
      end
    rescue
      raise CastError.new(input, self)
    end
    alias_method :[], :cast!

    def refine(name = nil, &config)
      self.class.new(name, self, &config)
    end

    # @return [Proc]
    def to_proc
      method(:cast!).to_proc
    end

    require 'type/definition/scalar'
    require 'type/definition/collection'
    require 'type/definition/nilable'

    # @return [String]
    def to_s
      name ? "Type::#{name}" : super
    end

    # @api private
    # @return [Array<Proc>]
    # Allows seeding with parent's validators
    def validators
      (@validators ||= [])
    end
    protected :validators

    # @api private
    # @return [Array<Proc>]
    # Allows seeding with parent's validators
    def castors
      (@castors ||= [])
    end
    protected :castors

    # used for configuring, but not after set up.
    # TODO: extract to DSL.
    # @api private
    def validate(&block)
      validators << block
    end
    private :validate

    # used for configuring, but not after set up.
    # TODO: extract to DSL.
    # @api private
    def cast(&block)
      castors << block
    end
    private :cast
  end
end
