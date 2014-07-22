class AddIndexToDirectmessages < ActiveRecord::Migration
  def change
    add_index :direct_messages, :sender_id
    add_index :direct_messages, :recipient_id
  end
end
