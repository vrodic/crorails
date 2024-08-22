class CreateTrainIgnores < ActiveRecord::Migration[7.2]
  def change
    create_table :train_ignores do |t|
      t.timestamps
    end
  end
end
