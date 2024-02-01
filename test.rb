# file to test api and get thoughts in order

require "poke-api-v2"
require "json"
require "http"

test = PokeApi.get(item: 'poke-ball')
test2 = test.sprites
test3 = test2.default
pp test.class
pp test2
pp test3

test4 = PokeApi.get(pokemon: "1")

pp test4.sprites.front_default

test5 = PokeApi.get(pokemon_species: "3")
pp test5.name
pp test5.capture_rate

# { #cookies
#   "pokemon" => { #pokemon
#     1 => { #pokemon_info
#       sprite_url
#       name
#       capture_rate
#     }
#     2 => {

#     }
#   }
#   "pokeball" => {
#     sprite_url
#     count
#   }
# }
