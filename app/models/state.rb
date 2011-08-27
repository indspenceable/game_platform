class State < ActiveRecord::Base
  belongs_to :game
  validates_presence_of :turn_id
  validates_presence_of :data
  serialize :data
end
