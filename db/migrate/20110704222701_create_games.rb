class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.text :state
      t.integer :game_id
      t.integer :move_id

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
