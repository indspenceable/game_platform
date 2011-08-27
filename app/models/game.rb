class Game < ActiveRecord::Base
  has_many :states
  has_many :deltas
  has_many :game_memberships
  has_many :players, :through => :game_memberships
  validates_presence_of :game_type

  def current_state
    states.order("turn_id DESC").first
  end
  def self.create_with_klass_and_players klass, players
    g = Game.create(:game_type => klass.game_type, :players => players)
    g.states.create(:data => klass.new(players.map{|x| x.name}), :turn_id => 1);
    g.save
    g
  end
end
