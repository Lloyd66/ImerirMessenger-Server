class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.references	:user
      t.string		:value
      t.datetime	:expires_at
      t.timestamps null: false
    end
  end
end
