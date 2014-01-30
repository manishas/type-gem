# encoding: utf-8
require 'type'

require_relative '../../spec_helper'

shared_examples_for 'Type::Definition::Scalar' do
  include_examples 'Type::Definition::Nilable compatibility'
  it { should be_a_kind_of Type::Definition }
  it { should be_a_kind_of Type::Definition::Scalar }
end

shared_examples_for 'Type::Integer' do
  it_should_behave_like 'Type::Definition::Scalar'
  it { should_not cast(nil) }

  it { should cast(414).unchanged }
  it { should cast('123').to(123) }
  it { should cast(456).to(456) }
  it { should cast(Math::PI).to(3) } # alabama ftw

  it { should_not cast('not a number') }
  it { should_not cast(Hash.new) }

  it { should validate(123) }
  it { should_not validate('123') }
end

describe Type::Integer do
  it_should_behave_like 'Type::Integer'
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
  it { should cast(nil).to(false) }
  it { should cast(Object.new).to(true) }
end

shared_examples_for 'Type::Float' do
  it_should_behave_like 'Type::Definition::Scalar'
  it { should_not cast(nil) }
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
  it { should_not cast(nil) }
  it_should_behave_like 'Type::Definition::Scalar'
  it { should cast(:abc).to('abc') }
end
