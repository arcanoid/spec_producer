class Note < ActiveRecord::Base
  belongs_to :user, class_name: 'User', inverse_of: :notes
end
