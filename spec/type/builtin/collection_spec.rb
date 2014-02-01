# encoding: utf-8
require 'type'

require_relative '../../spec_helper'

describe Type::Array do
  its(:to_s) { should match(/Type::Array/) }
  it { should_not cast(nil) }
  it { should be_a_kind_of Type::Definition::Collection }
  it { should validate(['asdf']) }
  it { should cast(['foo']).unchanged }
  it { should cast(['asdf', 1]).unchanged }
end

describe Type::Array.of(:String) do
  its(:to_s) { should match(/Type::Array\(.*String.*\)/) }
  it { should_not cast(nil) }
  it { should be_a_kind_of Type::Definition::Collection::Constrained }
  it { should validate(['asdf']) }
  it { should_not validate([nil, 'asdf']) }
  it { should_not validate([:asdf]) }
  it { should cast([:abc, 1]).to(['abc', '1']) }
  it { should_not cast([nil, 1]) }
end

describe Type::Array.of(:String?) do
  it { should be_a_kind_of Type::Definition::Collection::Constrained }
  it { should_not cast(nil) }
  it { should validate(['asdf']) }
  it { should validate([nil, 'asdf']) }
  it { should_not validate([:asdf]) }
  it { should cast([:abc, 1]).to(['abc', '1']) }
  it { should cast([nil, 1]).to([nil, '1']) }
end

describe Type::Hash do
  its(:to_s) { should match(/Type::Hash/) }
  it { should_not cast(nil) }
  it { should cast([[1, 2], [3, 4]]).to(1 => 2, 3 => 4) }
  it { should_not cast(17) }
end

describe Type::Hash.of(:String => :Integer) do
  its(:to_s) { should match(/Type::Hash\(.*String.*Integer.*\)/) }
  it { should_not cast(nil) }
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
  it { should_not cast(nil) }
  it { should_not validate([123, 456]) }
  it { should validate(Set.new([123, 456])) }
  it { should_not validate(17) }
  it { should cast([123, 456]).to(Set.new([123, 456])) }
  it { should cast(Set.new([123, 456])).to(Set.new([123, 456])) }
  it { should_not cast(17) }
end

describe Type::Set.of(:Integer) do
  its(:to_s) { should match(/Type::Set(.*Integer.*)/) }
  it { should_not cast(nil) }
  it { should validate(Set.new([1, 2, 3, 4])) }
  it { should_not validate([1, 2, 3, 4]) }
  it { should cast(Set.new([1, 2, 3, 4])).unchanged }
  it { should cast([1, 2, 3, 4]).to(Set.new([1, 2, 3, 4])) }
end
