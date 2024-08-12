class ChangeStopSequence < ActiveRecord::Migration[7.2]
  def up
    change_column :stop_times, :stop_sequence, :integer
  end
end
