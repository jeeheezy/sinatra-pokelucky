require "sinatra"
require "sinatra/reloader"
require "sinatra/cookies"
require "poke-api-v2"
require_relative "pokemon_spawn_calc"

get("/") do
  erb(:homepage)
end

post("/reset_cookies") do
  cookies.delete("pokeball")
  cookies.delete("party")
  redirect("/")
end

get("/exploring") do
  item_or_mon_prob = rand
  if item_or_mon_prob <= 0.2
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
      pokeball_hash = {"sprite_url" => sprite_url, "count" => 1}
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
        pokemon_info_hash = pokemon_hash[@dex_number.to_s]
        @sprite_url = pokemon_info_hash["sprite_url"]
        @name = pokemon_info_hash["name"]
      else
        pokemon_object = PokeApi.get(pokemon: "#{@dex_number}")
        @sprite_url = pokemon_object.sprites.front_default
        @name = pokemon_object.name
        @capture_rate = PokeApi.get(pokemon_species: "#{@dex_number}").capture_rate
        pokemon_info_hash = {"sprite_url" => @sprite_url, "name" => @name, "capture_rate" => @capture_rate}
        pokemon_hash[@dex_number.to_s] = pokemon_info_hash
        cookies["pokemon"] = JSON.generate(pokemon_hash)
      end
      # should probably look to refactor into another file cuz this conditional nest starting to look messy
    else
      pokemon_object = PokeApi.get(pokemon: "#{@dex_number}")
      @sprite_url = pokemon_object.sprites.front_default
      @name = pokemon_object.name
      @capture_rate = PokeApi.get(pokemon_species: "#{@dex_number}").capture_rate
      pokemon_info_hash = {"sprite_url" => @sprite_url, "name" => @name, "capture_rate" => @capture_rate}
      pokemon_hash = {}
      pokemon_hash[@dex_number.to_s] = pokemon_info_hash
      cookies["pokemon"] = JSON.generate(pokemon_hash)
    end
    erb(:pokemon)
  end
end

get("/party_and_items") do
end
