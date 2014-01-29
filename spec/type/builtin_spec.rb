# encoding: utf-8
require 'type'

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
    it { should_not cast(Object.new) unless described_class == Type::String }
  end
  it { should_not be_a_kind_of Type::Definition::Nilable }
  it { should_not be_nilable }
  it { should_not cast(nil) }
  it { should_not validate(nil) }
  it { should_not cast(Object.new) unless described_class == Type::String }
end

shared_examples_for 'Type::Definition::Scalar' do
  include_examples 'Type::Definition::Nilable compatibility'
  it { should be_a_kind_of Type::Definition }
  it { should be_a_kind_of Type::Definition::Scalar }
end

shared_examples_for 'Type::Integer' do
  it_should_behave_like 'Type::Definition::Scalar'

  it { should cast(414).unchanged }
  it { should cast('123').to(123) }
  it { should cast(456).to(456) }
  it { should cast(Math::PI).to(3) } # alabama ftw

  it { should_not cast('not a number') }
  it { should_not cast(Hash.new) }

  it { should validate(123) }
  it { should_not validate('123') }
end

shared_examples_for 'bounded Type::Integer' do
  it_should_behave_like 'Type::Integer'

  let(:range_max) { valid_range.end - (valid_range.exclude_end? ? 1 : 0) }
  let(:range_min) { valid_range.begin }

  it { should cast(range_max).unchanged }
  it { should cast(range_min).unchanged }

  it { should_not cast(range_max.next) }
  it { should_not cast(range_min.pred) }

  it { should validate(range_max) }
  it { should_not validate(range_max.next) }
end

describe Type::Integer do
  it_should_behave_like 'Type::Integer'
end

describe Type::Int32 do
  let(:valid_range) { (-1 << 31)...(1 << 31) }
  it_should_behave_like 'bounded Type::Integer'
end

describe Type::Int64 do
  let(:valid_range) { (-1 << 63)...(1 << 63) }
  it_should_behave_like 'bounded Type::Integer'
end

describe Type::UInt32 do
  let(:valid_range) { 0...(1 << 32) }
  it_should_behave_like 'bounded Type::Integer'
end

describe Type::UInt64 do
  let(:valid_range) { 0...(1 << 64) }
  it_should_behave_like 'bounded Type::Integer'
end

describe Type::Boolean do
  it_should_behave_like 'Type::Definition::Scalar'
  it { should validate true }
  it { should validate false }
  it { should_not validate nil }
  it { should_not validate 'true' }
  it { should_not validate 'false' }
  it { should cast(true).unchanged }
  it { should cast(false).unchanged }
end

shared_examples_for 'Type::Float' do
  it_should_behave_like 'Type::Definition::Scalar'
  it { should cast(10).to(10.0) }
  it { should cast(12.3).unchanged }
  it { should cast('12.3').to(12.3) }
  it { should cast('123e-1').to(12.3) }
  it { should cast('12.3e10').to(123000000000.0) }
  it { should cast('123e10').to(1230000000000.0) }
  it { should_not cast('a string') }
  it { should_not cast(Hash.new) }
  it { should validate(12.3) }
  it { should_not validate(12) }
end

describe Type::Float do
  include_examples 'Type::Float'
  it { should validate(Float::INFINITY) }
  it { should validate(-Float::INFINITY) }
end

describe Type::Float32 do
  include_examples 'Type::Float'
  it { should_not validate(Float::INFINITY) }
  it { should_not validate(-Float::INFINITY) }
end

describe Type::Float64 do
  include_examples 'Type::Float'
  it { should_not validate(Float::INFINITY) }
  it { should_not validate(-Float::INFINITY) }
end

describe Type::String do
  its(:to_s) { should match(/Type::String/) }
  it_should_behave_like 'Type::Definition::Scalar'
  it { should cast(:abc).to('abc') }
end

describe Type::Array do
  its(:to_s) { should match(/Type::Array/) }
  it { should be_a_kind_of Type::Definition::Collection }
  it { should validate(['asdf']) }
  it { should cast(['foo']).unchanged }
  it { should cast(['asdf', 1]).unchanged }
end

describe Type::Array.of(:String) do
  its(:to_s) { should match(/Type::Array\(.*String.*\)/) }
  it { should be_a_kind_of Type::Definition::Collection::Constrained }
  it { should validate(['asdf']) }
  it { should_not validate([nil, 'asdf']) }
  it { should_not validate([:asdf]) }
  it { should cast([:abc, 1]).to(['abc', '1']) }
  it { should_not cast([nil, 1]) }
end

describe Type::Array.of(:String?) do
  it { should be_a_kind_of Type::Definition::Collection::Constrained }
  it { should validate(['asdf']) }
  it { should validate([nil, 'asdf']) }
  it { should_not validate([:asdf]) }
  it { should cast([:abc, 1]).to(['abc', '1']) }
  it { should cast([nil, 1]).to([nil, '1']) }
end

describe Type::Hash do
  its(:to_s) { should match(/Type::Hash/) }
  it { should cast([[1, 2], [3, 4]]).to(1 => 2, 3 => 4) }
  it { should_not cast(17) }
end

describe Type::Hash.of(:String => :Integer) do
  its(:to_s) { should match(/Type::Hash\(.*String.*Integer.*\)/) }
  it { should be_a_kind_of Type::Definition::Collection::Constrained }
  it { should validate('foo' => 12) }
  it { should_not validate(foo: 12) }
  it { should_not validate('foo' => '12') }
  it { should cast('foo' => '12', :bar => 3).to('foo' => 12, 'bar' => 3) }
  it { should cast('foo' => 12, 'bar' => 3).unchanged }
  it { should cast([['12', 34], [56, '78']]).to('12' => 34, '56' => 78) }
  it { should_not cast('foo' => 'foo') }
end

describe Type::Set do
  it { should_not validate([123, 456]) }
  it { should validate(Set.new([123, 456])) }
  it { should_not validate(17) }
  it { should cast([123, 456]).to(Set.new([123, 456])) }
  it { should cast(Set.new([123, 456])).to(Set.new([123, 456])) }
  it { should_not cast(17) }
end

describe Type::Set.of(:Integer) do
  its(:to_s) { should match(/Type::Set(.*Integer.*)/) }
  it { should validate(Set.new([1, 2, 3, 4])) }
  it { should_not validate([1, 2, 3, 4]) }
  it { should cast(Set.new([1, 2, 3, 4])).unchanged }
  it { should cast([1, 2, 3, 4]).to(Set.new([1, 2, 3, 4])) }
end
