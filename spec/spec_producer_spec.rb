require 'spec_helper'

describe SpecProducer do
  subject { SpecProducer }

  context 'Configuration' do
    it { expect(SpecProducer).to be_a SpecProducer::Configuration }
    it { expect(SpecProducer.configuration).to be_present }

    context 'default config' do
      it { expect(SpecProducer.configuration.raise_errors).to be true }
    end

    context 'Configuring' do
      it 'should set all config values' do
        SpecProducer.configure do |config|
          config.raise_errors = false
        end
        expect(SpecProducer.configuration.raise_errors).to be false
        SpecProducer.configuration.raise_errors = true
      end
    end
  end

  describe '.produce' do
    context 'when no options is provided' do
      it 'should produce all registered spec types' do
        expect(SpecProducer.registry).to_not be_empty
        SpecProducer.registry.types.each do |spec_type|
          expect(subject).to receive(:produce_spec).with(spec_type)
        end

        # Fire
        SpecProducer.produce
      end
    end

    context 'only option' do
      before { expect(subject.registry.registered?(:models)).to be true }
      it 'produces only the specs provided' do
        expect(subject).to receive(:produce_spec).with(:models)

        # Fire
        SpecProducer.produce(only: [:models, :controllers])
      end
    end
    context 'except option' do
      it 'produces all the secs except the given ones' do
        all_types = SpecProducer.registry.types
        except = [:controllers, :models, :views]
        remaining = all_types -= except
        remaining.each {|type|
          expect(subject).to receive(:produce_spec).with(type)
        }
        SpecProducer.produce(except: except)
      end
    end
  end

  context '.run' do
    it 'should delegate to SpecRunner' do
      args = double('args')
      expect(SpecProducer::SpecRunner).to receive(:run).with(args)
      SpecProducer.run(args)
    end
  end

  it { expect(subject.registry).to be_a SpecProducer::Producers::Registry }

  it 'should have registered all producers' do
    expect(subject.registry.registrations.size).to eq 1
  end

  describe '.register' do
    it 'should register to the registry the given type and klass' do
      expect(subject.registry).to receive(:register).with(:type, Class)
      subject.register(:type, Class)
    end
  end

  describe '.produce_spec' do
    it { expect{subject.produce_spec(:models)}.to_not raise_error }
    it 'should produce the given spec type' do
      type = :models
      producer = double('Producer')
      expect(subject).to receive(:lookup!).with(type).and_return(producer)
      result = subject.produce_spec(:models)
      expect(result).to eq producer
    end
  end
  describe '.lookup!' do
    it 'returns a registered spec producer' do
      model_producer = subject.lookup!(:models)
      expect(model_producer).to be_a SpecProducer::Producers::ModelsProducer
      expect(model_producer.type).to eq :models
    end
    it 'returns all registered spec producers'
  end
end
