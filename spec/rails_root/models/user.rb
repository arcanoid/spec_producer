class User < ActiveRecord::Base
  has_many :notes, autosave: :true, dependent: :destroy
  validates_presence_of :name
end
