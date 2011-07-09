require './game_state.rb'
require './units.rb'

module DC
  class Game
    #TODO - make setting up a game at the end
    def initialize map_file, character, players
      #map = load_map_from map_file 
      @game_states = [DC::GameState.new(
        Array.new(10){Array.new(10){:empty}}, #MAP
        [Imp.new(0,'danny',[0,0]), Ent.new(0,'bob',[3,2])], #CHARACTERS
        ['danny','bob'])
      ]
    end

    def current_state_number
      @game_states.size
    end
    def current_map
      current_state.map
    end
    def current_state
      @game_states.last
    end
    def characters requesting_player
      current_state.units.reject do |c|
        !current_state.visible?(requesting_player, c[:location])
      end
    end

    def end_turn player, *_
      next_state = current_state.dup
      transitions = next_state.end_turn(player)
      @game_states << next_state
      transitions 
    rescue IllegalOrderError => e
      puts "Well, clearly it wasn't your turn... bro."
      return "You fucked up again, bro."
    end

    def submit_order player, unit, order, additional_data = nil
      next_state = current_state.dup
      transitions = next_state.send(order,player,unit,additional_data)
      @game_states << next_state
      transitions
    rescue IllegalOrderError => e
      puts e.backtrace
      puts e
      return "You fucked up, bro."
    end
  end
end
