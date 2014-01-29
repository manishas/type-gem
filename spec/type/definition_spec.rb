# encoding: utf-8
require 'type'

Proc.const_set(:IDENTITY, ->(x) { x }) unless defined?(Proc::IDENTITY)

describe Type::Definition do
  it { should be_an_instance_of Module }
  context 'implementation' do
    let(:implementation) do
      Class.new { include Type::Definition }
    end
    subject { implementation }
    it { should be <= Type::Definition }
    context 'bare instance' do
      let(:instance) { implementation.new }
      subject { instance }
      it { should be_a_kind_of Type::Definition }
      it { should validate :anything }
      it { should cast('a string').unchanged }
      it { should respond_to :to_proc }
    end
    context 'liberal instance (validates anything)' do
      let(:instance) do
        implementation.new do
          validate { true }
          cast(&Proc::IDENTITY)
        end
      end
      subject { instance }
      it { should validate :anything }
      it { should cast('a string').unchanged }
    end
    context 'conservative instance (validates :exact_match)' do
      let(:instance) do
        implementation.new do
          validate { |x| x == :exact_match }
          cast(&Proc::IDENTITY)
        end
      end
      subject { instance }
      it { should_not validate :random_input }
      it { should validate :exact_match }
      it { should_not cast('a string') }
      it { should cast(:exact_match).unchanged }
    end
    context 'with inheritance (divisible by 5 inherits divisible by 3)' do
      let(:parent_instance) do
        implementation.new do
          validate { |x| (x % 3).zero? }
        end
      end
      let(:instance) do
        implementation.new(nil, parent_instance) do
          validate { |x| (x % 5).zero? }
        end
      end
      subject { instance }
      it { should_not validate 3 }
      it { should_not validate 5 }
      it { should validate 15 }
      it { should validate 90 }
      it { should cast(15).unchanged }
      it { should cast(90).unchanged }
      it { should_not cast(3) }
      it { should_not cast(5) }
    end
    context '#to_proc' do
      let(:instance) do
        implementation.new do
          cast { |x| String(x) }
          validate { |x| x.kind_of?(String) }
        end
      end
      subject { instance.to_proc }
      it { should be_a_kind_of Proc }
      context 'when called' do
        it 'should cast the input' do
          expect(instance.to_proc.call(:asdf)).to eq 'asdf'
          expect([:foo, 3].map(&instance)).to eq ['foo', '3']
        end
      end
    end
  end
end
