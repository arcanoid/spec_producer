module SpecProducer
  module SpecRunner
    describe '.run' do
      context 'when no types are given' do
        it 'runs the rake command only' do
          expect(SpecRunner).to receive(:system).with('bundle exec rake')
          SpecRunner.run
        end
      end

      context 'when some types are given' do
        let(:types) { [:models, :controllers] }
        it 'should run the corresponding rspec tests' do
          expect(SpecRunner).to receive(:system).with(('bundle exec rspec spec/models'))
          expect(SpecRunner).to receive(:system).with(('bundle exec rspec spec/controllers'))
          SpecRunner.run(types)
        end
      end
    end
  end
end
