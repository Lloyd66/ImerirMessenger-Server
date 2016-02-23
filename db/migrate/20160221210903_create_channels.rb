class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string		:name
      t.datetime	:last_message_at
      t.references	:creator
      t.boolean		:is_direct_message_channel, :default => false
      t.timestamps null: false
    end

    create_table :channels_users, :id => false do |t|
      t.references  :channel
      t.references  :user
    end
  end
end
