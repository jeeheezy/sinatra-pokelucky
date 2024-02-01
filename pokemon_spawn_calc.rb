# creating different brackets of Pokemon based on their rarity for spawn using their Kanto Pokedex numbers

class Pokemon_spawn
  def initialize
    starters= (1..9).to_a #starters and their evolutions
    fossils= (138..142).to_a #fossil pokemons and their evolutions
    extraneous_rares= (131..137).to_a + (147..149).to_a #lapras, ditto, eeveeloutions, porygon, and dragonite evolution line

    @v_rares = starters + fossils + extraneous_rares
    @legendaries = [144, 145, 146, 150, 151] #gen 1 legendaries: 3 birds plus mew and mewtwo
    @rares = [106, 107, 113, 115, 143] #hitmonlee, hitmonchan, chansey, kangaskhan, snorlax
    @commons = []

    (1..151).each { |number|
      @commons.push(number) unless @v_rares.include?(number) || @legendaries.include?(number) || @rares.include?(number
      )
    }
  end

  def generate_spawn
    rarity = 1 + rand(100)
    if rarity <= 60 # 60% chance for commons
      spawn_id = @commons.sample
    elsif (rarity > 60 && rarity <= 85) # 25% chance for rares 
      spawn_id = @rares.sample
    elsif (rarity > 85 && rarity <= 95) # 10% chance for v_rares
      spawn_id = @v_rares.sample
    else # 5% chance for legendaries
      spawn_id = @legendaries.sample
    end
    return spawn_id
  end
end
