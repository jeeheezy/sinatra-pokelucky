# just creating outline of what methods I might make, not sure if I can use cookies here so might need to pass it in?
require "sinatra"
require "sinatra/cookies"
require "poke-api-v2"

def update_pokemon_hash(dex_number, sprite_url, name, base_hp, capture_rate)
  pokemon_info_hash = {"sprite_url" => @sprite_url, "name" => @name, "capture_rate" => @capture_rate, "base_hp" => @base_hp}
  
end

def pokeball_info_store
end

def pokemon_info_pull
end

def pokemon_info_store
end
