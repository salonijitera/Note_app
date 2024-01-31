class AddEmailVerificationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_email_verified, :boolean, default: false
  end
end
