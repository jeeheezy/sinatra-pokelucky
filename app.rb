require "sinatra"
require "sinatra/reloader"
require "sinatra/cookies"
require "poke-api-v2"
require_relative "pokemon_spawn_calc"
require_relative "capture_formula"
$saved_encounter = false
$failed_encounter = false

get("/") do
  erb(:homepage)
end

post("/reset_cookies") do
  cookies.delete("pokeball")
  cookies.delete("party")
  cookies.delete("current_encounter")
  redirect("/")
end

get("/exploring") do
  # if had previously thrown a pokeball at an encounter
  if $saved_encounter
    current_encounter = JSON.parse(cookies["current_encounter"])
    @dex_number = current_encounter["id"]
    pokemon_hash= JSON.parse(cookies["pokemon"])
    pokemon_info_hash = pokemon_hash[@dex_number.to_s]
    @sprite_url = pokemon_info_hash["sprite_url"]
    @name = pokemon_info_hash["name"]
    @pokeball_count = JSON.parse(cookies["pokeball"])["count"]
    $saved_encounter = false
    if $failed_encounter
      cookies.delete("current_encounter")
      $failed_encounter = false
      erb(:failed_encounter)
    else
      erb(:capture_reattempt)
    end
  # if generating new encounter (whether pokeball or pokemon) 
  else
    cookies.delete("current_encounter") # getting rid of any saved encounter if there were any
    item_or_mon_prob = rand
    if item_or_mon_prob <= 0.5
      # spawn pokeball
      # checking if pokeball png and counts already stored in cookies
      if cookies.key?("pokeball")
        pokeball_hash = JSON.parse(cookies["pokeball"])
        @sprite_url = pokeball_hash["sprite_url"]
        @pokeball_count = (pokeball_hash["count"]) + 1
        pokeball_hash["count"] = @pokeball_count
        cookies["pokeball"] = JSON.generate(pokeball_hash)
      else
        @sprite_url = PokeApi.get(item: 'poke-ball').sprites.default
        @pokeball_count = 1
        pokeball_hash = {"sprite_url" => @sprite_url, "count" => 1}
        cookies["pokeball"] = JSON.generate(pokeball_hash)
      end
      # figure out a way to display pokeball count and sprite in different screens, but otherwise can call the instance variables in erb
      erb(:pokeball)

    else
      # spawn pokemon
      probability_brackets = Pokemon_spawn.new
      @dex_number= probability_brackets.generate_spawn
      if cookies.key?("pokemon")
        pokemon_hash= JSON.parse(cookies["pokemon"])
        if pokemon_hash.key?(@dex_number.to_s)
          # if pokemon already saved in hash, pull information from hash
          pokemon_info_hash = pokemon_hash[@dex_number.to_s]
          @sprite_url = pokemon_info_hash["sprite_url"]
          @name = pokemon_info_hash["name"]
          @capture_rate = pokemon_info_hash["capture_rate"]
          @base_hp = pokemon_info_hash["base_hp"]
        else
          # if pokemon not already saved in hash, generate information from API and save into hash
          pokemon_object = PokeApi.get(pokemon: "#{@dex_number}")
          @sprite_url = pokemon_object.sprites.front_default
          @name = pokemon_object.name
          @base_hp = pokemon_object.stats[0].base_stat
          @capture_rate = PokeApi.get(pokemon_species: "#{@dex_number}").capture_rate
          pokemon_info_hash = {"sprite_url" => @sprite_url, "name" => @name, "capture_rate" => @capture_rate, "base_hp" => @base_hp}
          pokemon_hash[@dex_number.to_s] = pokemon_info_hash
          cookies["pokemon"] = JSON.generate(pokemon_hash)
        end
        # should probably look to refactor into another file cuz this conditional nest starting to look messy
      else
        # if pokemon was not already saved in hash
        pokemon_hash = {}
        pokemon_object = PokeApi.get(pokemon: "#{@dex_number}")
        @sprite_url = pokemon_object.sprites.front_default
        @name = pokemon_object.name
        @base_hp = pokemon_object.stats[0].base_stat
        @capture_rate = PokeApi.get(pokemon_species: "#{@dex_number}").capture_rate
        pokemon_info_hash = {"sprite_url" => @sprite_url, "name" => @name, "capture_rate" => @capture_rate, "base_hp" => @base_hp}
        pokemon_hash[@dex_number.to_s] = pokemon_info_hash
        cookies["pokemon"] = JSON.generate(pokemon_hash)
      end
      # still accessing pokeball cookies when spawning pokemon to display number of pokeballs on hand, and determine if catch button should be accessible
      if cookies.key?("pokeball")
        pokeball_hash = JSON.parse(cookies["pokeball"])
        @pokeball_count = (pokeball_hash["count"])
      else
        @pokeball_count = 0
      end
      cookies["current_encounter"] = JSON.generate({"id" => @dex_number, "name" => @name,"capture_rate" => @capture_rate, "base_hp" => @base_hp})
      erb(:pokemon)
    end
  end
end


post("/catch") do
  # every catch attempt will require using a pokeball so updating the count in hash
  pokeball_hash = JSON.parse(cookies["pokeball"])
  pokeball_count = (pokeball_hash["count"]) - 1
  pokeball_hash["count"] = pokeball_count
  cookies["pokeball"] = JSON.generate(pokeball_hash)
  # take capture rate and base hp of current encounter for capture formula
  current_encounter = JSON.parse(cookies["current_encounter"])
  capture_rate = current_encounter["capture_rate"]
  base_hp = current_encounter["base_hp"]
  catch_result = capture(capture_rate, base_hp)
  if catch_result == false
    $saved_encounter = true
    continue_or_flee = rand
    if continue_or_flee <= 0.3
      $failed_encounter = true
    end
    redirect("/exploring")
  else
    redirect("/captured")
  end
end

post("/run") do
  cookies.delete("current_encounter")
  redirect("/")
end

get("/captured") do
  # can check for pokeball hash here since must be given that pokeball hash exists to capture, otherwise capture button should not render
  @sprite_url = JSON.parse(cookies["pokeball"])["sprite_url"]
  current_encounter = cookies["current_encounter"]
  erb(:captured)
end

get("/release") do
end

get("/party_and_items") do
end
