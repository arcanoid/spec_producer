require "rails_helper"

describe User, :type => :model do
  it { is_expected.to respond_to :id, :id= }
  it { is_expected.to respond_to :email, :email= }
  it { is_expected.to respond_to :name, :name= }
  it { is_expected.to respond_to :age, :age= }
  it { is_expected.to respond_to :created_at, :created_at= }
  it { is_expected.to respond_to :updated_at, :updated_at= }

  # Columns
  it { is_expected.to have_db_column :id }
  it { is_expected.to have_db_column :email }
  it { is_expected.to have_db_column :name }
  it { is_expected.to have_db_column :age }
  it { is_expected.to have_db_column :created_at }
  it { is_expected.to have_db_column :updated_at }

  # Validators

  it { is_expected.to validate_presence_of :name }


  describe 'valid?' do
    subject { FactoryGirl.build(:user).valid? }

    it { is_expected.to eq(true) }
  end


  # Associations
    it { is_expected.to have_many(:notes).autosave(:true).dependent(:destroy) }
end
