class CreateDeltas < ActiveRecord::Migration
  def self.up
    create_table :deltas do |t|
      t.integer :game_id
      t.integer :turn_id
      t.text :data

      t.timestamps
    end
  end

  def self.down
    drop_table :deltas
  end
end
