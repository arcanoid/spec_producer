require 'spec_helper'
module SpecProducer
  module Producers
    describe ModelsSpecProducer do
      subject { ModelsSpecProducer.new(:models) }
      it { expect(subject).to be_a Producers::Base }

      describe '.call' do
        it 'foo' do
          subject.call
        end
      end
    end
  end
end
