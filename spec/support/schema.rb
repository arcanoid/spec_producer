ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string :email
    t.string :name
    t.integer :age

    t.timestamps
  end

  create_table :notes, force: true do |t|
    t.string :body
    t.references :user, index: true, foreign_key: true
  end
end
