# encoding: utf-8

RSpec::Matchers.define(:cast) do |input|
  match do |definition|
    begin
      @actual = definition.cast!(input)
      if @chained
        failure_message_for_should do
          "Expected result to be #{@expected.inspect}(#{@expected.class}) " +
          "but got #{@actual.inspect}(#{@actual.class}) instead"
        end
        @expected == @actual
      else
        true
      end
    rescue Type::CastError => cast_error
      failure_message_for_should do
        "#{definition} failed to cast #{input.inspect}(#{input.class}) " +
        "by raising #{cast_error}(#{cast_error.cause})."
      end
      false
    end
  end

  description do
    "cast #{input.inspect}(#{input.class})"
  end

  chain(:to) do |expected|
    description do
      "cast #{input.inspect}(#{input.class}) to #{expected.inspect}(#{expected.class})"
    end
    @chained = true
    @expected = expected
  end

  chain(:unchanged) do
    description do
      "cast #{input.inspect}(#{input.class}) unchanged"
    end
    @chained = true
    @expected = input
  end
end

RSpec::Matchers.define :validate do |input|
  match do |definition|
    definition.valid?(input)
  end
  description do
    "validate #{input.inspect}(#{input.class})"
  end
end

shared_examples_for 'Type::Definition::Nilable compatibility' do
  context 'when nilable' do
    subject { described_class.nilable }
    it { should be_a_kind_of Type::Definition::Nilable }
    it { should be_nilable }
    it { should cast(nil).to(nil) }
    it { should validate(nil) }
  end
  it { should_not be_a_kind_of Type::Definition::Nilable }
  it { should_not be_nilable }
  it { should_not validate(nil) }
end
