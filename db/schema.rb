# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

<<<<<<< HEAD
ActiveRecord::Schema.define(:version => 20110709230451) do
=======
ActiveRecord::Schema.define(:version => 20110710180745) do
>>>>>>> 95e8eec7ec66a6cd09401279bf4e167eb5f243ea

  create_table "games", :force => true do |t|
    t.text     "state"
    t.integer  "game_id"
    t.integer  "move_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", :force => true do |t|
    t.string   "name"
    t.integer  "game_id"
    t.string   "current_challenge"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "email"
  end

  create_table "transitions", :force => true do |t|
    t.integer  "game_id"
    t.integer  "turn_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
