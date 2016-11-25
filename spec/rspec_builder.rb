require 'spec_helper'

module SpecProducer
  module RspecBuilders
    pending 'TODO'
    describe Base do
      subject do
        Klass = Class.new(Object) do
          attr_accessor :name, :age
        end

        Klass.new
      end

      it '.build' do
        _subject = subject
        _subject.name = 'lapis'
        _subject.age = 22

        result = SpecProducer::RspecBuilders::Base.build do |b|
          b.spec 'User', 'model' do
            b.subject 'build(:some)'
            b.it { validates_presence_of(_subject.name) }
            b.it { expect(:age).to eq(_subject.age) }
            b.should_validate_presence_of(:name)
            b.should_belong_to(:user)
            b.should_have_many(:notes)

            b.context 'some' do
              b.subject _subject.age
              b.it { expect(_subject.age).to eq(22) }
            end

            b.context('foo') do
              b.subject 'build(:user)'
              b.it { should_be(:some) }
              b.it { responds_to(:some) }
              b.it { responds_to(:some) }
              b.it { responds_to(:some, :some, :some) }
              b.should_be(:valid)
              b.should_belong_to(:user)
            end

            b.context 'associations' do
              b.subject _subject.age
              b.it { should_have_many(:notes) }
              b.it { should_belong_to(:person) }
              b.it { should_have_one(:profile) }
              b.context 'inner' do
                b.it { should_have_one(:post) }
                b.it { has_many(:posts) }
                b.it { has_db_column(:id) }
              end
            end
          end
        end # end builder
      end

    end
  end
end
