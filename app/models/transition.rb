class Transition < ActiveRecord::Base
  belongs_to :game
  validates_presence_of :turn_id
  validates_presence_of :data
end
