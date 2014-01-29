# encoding: utf-8

module Type
  module Definition
    # Re-open Collection to add constraint methods
    class Collection
      # @overload constrain(constraint)
      #   @param constraint [Type::Definition]
      # @overload constrain(constraint)
      #   @param constraint [Hash{Type::Defintion=>Type::Defintion}]
      #     a single-element hash whose key is the constraint for keys,
      #     and whose value is a constraint for values
      # @return [Type::Defintion::Collection::Constrained]
      def constrain(constraint)
        Constrained.new(self, constraint)
      end
      alias_method :of, :constrain

      # @return [False]
      def constrained?
        false
      end

      # A Constrained collection also validates and casts the contents
      # of the collection.
      class Constrained < Collection
        # @api private (See Type::Defintion::Collection#constrain)
        def initialize(parent, constraint)
          @constraints = Array(constraint).flatten.map { |c| Type.find(c) }

          validators  << method(:validate_each?)
          castors     << method(:cast_each!)

          super(nil, parent)

          @name = "#{parent.name}(#{@constraints.join('=>')})"
        end
        attr_reader :constraints

        # @return [True]
        def constrained?
          true
        end

        # @api private
        def to_s
          parent_name = @parent && @parent.name
          return super unless parent_name
          "Type::#{parent_name}(#{@constraints.join('=>')})"
        end

        protected

        # @api private
        # @param enum [Enumerable]
        # @return [Boolean]
        def validate_each?(enum)
          enum.all? do |item|
            next @constraints.first.valid?(item) if @constraints.size == 1
            @constraints.zip(item).all? do |constraint, value|
              constraint.valid?(value)
            end
          end
        end

        # @api private
        # @param enum [Enumerable]
        # @return [Enumerable]
        def cast_each!(enum)
          enum.map do |item|
            next @constraints.first.cast!(item) if @constraints.size == 1
            @constraints.zip(item).map do |constraint, value|
              constraint.cast!(value)
            end
          end
        end
      end
    end
  end
end
