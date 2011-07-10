class Player < ActiveRecord::Base
  belongs_to :game
  validates_presence_of :name
  validates_uniqueness_of :name

  def self.valid_name? n
    !!(n=~/[a-z]{3,10}/)
  end
end
