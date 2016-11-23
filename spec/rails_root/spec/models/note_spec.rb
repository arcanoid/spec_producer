require "rails_helper"

describe Note, :type => :model do
  it { is_expected.to respond_to :id, :id= }
  it { is_expected.to respond_to :body, :body= }
  it { is_expected.to respond_to :user_id, :user_id= }

  # Columns
  it { is_expected.to have_db_column :id }
  it { is_expected.to have_db_column :body }
  it { is_expected.to have_db_column :user_id }

  describe 'valid?' do
    subject { FactoryGirl.build(:note).valid? }

    it { is_expected.to eq(true) }
  end


  # Associations
  it { is_expected.to belong_to(:user) }
end
