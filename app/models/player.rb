class Player < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  def self.valid_name? n
    !!(n=~/[a-z]{3,10}/)
  end
  def self.find_by_name n
    first(:conditions => {:name => n})
  end
end
