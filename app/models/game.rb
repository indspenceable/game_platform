class Game < ActiveRecord::Base
  has_many :states
  has_many :deltas
  has_many :players
  validates_presence_of :game_type

  def current_state
    states.order("turnd_id DESC").first
  end
end
