class Player < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  def self.valid_name? n
    !!(n=~/[a-z]{3,10}/)
  end

  def self.create_player(name, email, password)
    return nil unless valid_name? name
    player = Player.create!({:name => name, :email => email})
    player.password = password
  end

  def self.authenticate(name, pass)
    player = Player.find_by_name name
    return nil if player.nil?
    return player if player.hashed_password == Player.encrypt(pass, player.salt)
    nil
  end

  def password=(pass)
    self.salt = Player.random_string(10) unless self.salt?
    self.hashed_password = Player.encrypt pass, salt
    self.save!
  end

  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass + salt)
  end

  def self.random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
end
