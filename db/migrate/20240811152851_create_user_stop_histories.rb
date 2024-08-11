class CreateUserStopHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :user_stop_histories do |t|
      t.integer :user_id
      t.string :stop_id
      t.string :stop_type

      t.timestamps
    end
  end
end
