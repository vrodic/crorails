class ChangeRideStatus < ActiveRecord::Migration[7.2]
  def change
    change_column :rides, :status, :integer, default: 0
  end
end
