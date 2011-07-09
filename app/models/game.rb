require 'game_state.rb'
class Game < ActiveRecord::Base
  validates_presence_of :game_id
  def self.find_newest_state g_id
    r = Game.all(:conditions => {:game_id => g_id})
    return nil if r.empty?
    r.sort! {|l,r| l.move_id <=> r.move_id} 
    YAML.load(r.last.state)
  end

  def self.generate_new_game
    #find a new id
    new_game_id = 1
    loop do
      break unless Game.first(:conditions => {:game_id => new_game_id})
      new_game_id += 1
    end
    
    g = Game.new( :game_id => new_game_id, :state => YAML.dump(DC::GameState.new))
    g.save
    new_game_id
  end
end
