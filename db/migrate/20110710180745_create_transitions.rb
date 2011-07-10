class CreateTransitions < ActiveRecord::Migration
  def self.up
    create_table :transitions do |t|
      t.integer :game_id
      t.integer :turn_id
      t.text :data

      t.timestamps
    end
  end

  def self.down
    drop_table :transitions
  end
end
