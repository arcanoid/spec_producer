require 'spec_helper'

module SpecProducer
  module Producers
    describe Registry, type: :model do
      it { expect(subject).to be_empty }
      it { expect(subject.types).to be_empty }
 
      context 'enumerable' do
        it { expect(subject).to be_a Enumerable }
        it { expect(subject.each).to be_a Enumerator }
        it{ expect{subject.each.next}.to raise_error(StopIteration) }
      end

      context 'registering a producer' do
        before { subject.register(:models, Producers::ModelsSpecProducer) }
        it { expect(subject.size).to eq 1 }
        it { expect(subject).to_not be_empty }
        it { expect(subject.types).to eq [:models] }
        it { expect(subject.registered?(:models)).to be true }
        it { expect(subject.lookup!(:models)).to be_a Producers::ModelsSpecProducer }
      end
      context 'when a producer type cannot be fetched' do
        it { expect{subject.lookup!(:non_existing)}.to raise_error(ArgumentError) }
      end
    end
  end
end
