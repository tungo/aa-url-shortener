class AddPremiumToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :premium, :boolean, default: false
  end
end
