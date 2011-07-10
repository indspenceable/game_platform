class AddAuthentication < ActiveRecord::Migration
  def self.up
    add_column :players, :hashed_password, :string
    add_column :players, :salt, :string
    add_column :players, :email, :string
  end

  def self.down
    remove_column :players, :hashed_password
    remove_column :players, :salt
    remove_column :players, :email
  end
end
