#TODO - make units just hashes.
require 'units.rb'
class IllegalOrderError < RuntimeError; end

module DC
  class GameState
    attr_reader :units
    def initialize map = Array.new(10){Array.new(10){:empty}},
      units = [Imp.new(0,'danny',[0,0]), Ent.new(0,'bob',[3,2])], 
      players = ['danny','bob']
      @map = map
      @units = units 
      @current_player = 0
      @players = players
    end

    # GameState#map => Array of Array of Tiles
    def map
      @map.dup 
    end

    def current_player
      @players[@current_player]
    end

    # make a new copy of the map (in case you end up being able to change
    # the terrain)
    # and a new copy of the units so that you can alter them
    def initialize_copy source
      super
      @units = @units.dup.map{|u| u.dup}
      @map = @map.dup.map{|c| c.dup}
    end

    # General case - can any unit move through here?
    # if the location is not in the map, false
    def can_path_through x,y
      @map[x][y] != :wall
    rescue
      false
    end

    # true if this tile is passable, generally, and no other player has a unit in that tile.
    def player_can_path_through? player, x,y
      can_path_through(x,y) && !(units.reject{|v| v.player ==player}.find{|v| v.location == [x,y]})
    end

    #square distance between two points
    def distance a, b
      (a[0] - b[0]).abs + (a[1] - b[1]).abs
    end
    def adjacent? a, b
      distance(a,b) == 1
    end

    #path should be a [x,y] pairs, each 1 distance from the next
    def valid_path? unit, path
      path.inject(@units[unit].location) do |p,c|
        return false unless adjacent?(p, c) && can_path_through(*c)
        c
      end
      true
    end

    def visible? player, location
      x,y = location
      return true if @map[x][y] == :illuminated

      units.reject{|v| v.player != player}.each do |v|
        return true if distance(v.location,location) <= v.sight_range
      end
      false
    end

    
    def json_for player
      val = {}
      val[:map] = @map
      val[:players] = @players
      val[:current_player] = @current_player
      val[:units] = []
      @units.each do |u|
        val[:units] << u.simple if visible? player, u.location
      end
      val
    end


    def end_turn player
      raise IllegalOrdererror.new("Wrong player is ending the turn.") unless current_player == player

      @current_player = (@current_player + 1) % @players.size

      transitions = {}
      @players.each do |p|
        transitions[p] = {:type => :next_turn, :new_player => current_player}
      end
      transitions 
    end

    # Do a movement. Basically, any character can do this. 
    # So, it's pretty key.
    def movement player, unit, path
      raise IllegalOrderError.new("Wrong current player") unless current_player == player
      raise IllegalOrderError.new("That unit is already spent.") if units[unit].spent
      raise IllegalOrderError.new("Invalid path.") unless valid_path?(unit,path)
      #valid move

      actual_travled_path = path.take_while{ |spot| player_can_path_through?(player, *spot)}
      units[unit].location = actual_travled_path.last
      units[unit].spent = :moved

      transitions = {}
      @players.each do |p|
        player_path = actual_travled_path.dup
        player_path.reject!{|v| !visible?(p,v)} unless p == player
        transitions[p] = { :type => :move_sprite, :sprite => @units[unit].sprite, :path => player_path } if player_path.size > 0
      end
      #(animations[player] ||= {})[:path] = { :type => :move_sprite, :sprite => @units[unit].sprite, :path => actual_travled_path }
      transitions 
    end

    def attack player, unit, target
      raise IllegalOrderError.new("Wrong current player.") unless current_player == player
      raise IllegalOrderError.new("That unit is already spent.") if units[unit].spent == true 
      raise IllegalOrderError.new("Out of range to attack.") unless adjacent?(units[unit].location, units[target].location)
      #should that have instead checked distance <= units[unit][:attack_distance]

      #figure out how much damage to do
      damage_range = units[unit].damage
      damage_dealt = rand(damage_range.end - damage_range.begin) + damage_range.begin - units[target].shield
      damage_dealt = 0 if damage_dealt < 0
      units[unit].spent = true

      units[unit].health -= damage_dealt

      #did we kill them? 
      transitions = {}
      @players.each do |p|
        transitions[p] = {:type => :damage, :ammount => damage_dealt, :location => @units[target].location} if visible? p, units[target].location
      end
      transitions 
    end
    def shadow_jump player, unit, dest
      raise IllegalOrderError.new("Wrong current player.") unless current_player == player
      raise IllegalOrderError.new("That unit is already spent.") if units[unit].spent
      raise IllegalOrderError.new("That unit can't shadow jump.") unless units[unit].abilities.include? :shadow_jump
      raise IllegalOrderError.new("That isn't a valid location to jump to.") unless player_can_path_through(player, *dest) && (distance(@units[unit].location, dest)==2)

      #teleport to the destination
      starting_location = @units[unit].location
      @units[unit].location = dest

      transition = {}
      @players.each do |p|
        player_path = [starting_location, dest]
        player_path.reject!{|v| !visible?(p,v)} unless p == player
        player_path *= 10 if player_path.size > 1
        transitions[p] = { :type => :move_sprite, :sprite => @units[unit].sprite, :path => player_path }
      end
      transitions
    end
    def root player, unit, _
      raise IllegalOrderError.new("Wrong current player.") unless current_player == player
      raise IllegalOrderError.new("That unit is already spent.") if units[unit].spent
      raise IllegalOrderError.new("That unit can't root.") unless units[unit].abilities.include? :root

      units[unit].health += 5

      transitions = {} 
      @players.each do |p|
        transitions[p] = {:type => :effect, :sprite => :root, :location => @units[unit].location} if visible? p, units[unit].location
      end
      transitions 
    end
  end
end

