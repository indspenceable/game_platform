module DC
  class Unit
    attr_reader :id, :player
    attr_accessor :location, :spent
    def initialize id, owner, location
      @id = id
      @player = owner
      @location = location
      @health = max_health
      @spent = false
    end

    def simple
      { 'id' => @id,
        'player' => @player,
        'location' => @location,
        'health' => @health,
        'spent' => @spent,
        'sprite' => sprite.to_s
      }
    end

    #default stats
    def sight_range
      2
    end
    def damage
      4..6
    end
    def shield
      0
    end
    def abilities
      []
    end

    #getter and setter for health
    def health
      @health
    end
    def health= x
      @health = if x > max_health
                  max_health
                elsif x < 0
                  0
                else
                  x
                end
    end
    def max_health
      10
    end
  end

  class Imp < Unit
    def sprite
      :imp
    end
    def damage
      3..5
    end
    def abilities
      [:dodge]
    end
  end

  class Ent < Unit
    def sprite
      :ent
    end
    def damage
      5..7
    end
    def abilities
      [:root]
    end
    def max_health
      13
    end
  end
end
