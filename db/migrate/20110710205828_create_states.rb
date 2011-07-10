class CreateStates < ActiveRecord::Migration
  def self.up
    create_table :states do |t|
      t.text :data
      t.integer :turn_id
      t.integer :game_id

      t.timestamps
    end
  end

  def self.down
    drop_table :states
  end
end
