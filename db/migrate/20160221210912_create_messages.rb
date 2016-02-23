class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references	:channel
      t.string		:message
      t.references	:author
      t.timestamps null: false
    end
  end
end
