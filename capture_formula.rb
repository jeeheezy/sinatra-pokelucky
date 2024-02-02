# loosely based off capture infographic from https://www.reddit.com/r/pokemon/comments/43ndwm/gen_iii_iv_catch_rate_infographic_i_made_a_while/
def capture(capture_rate, base_hp)
  max_hp = (15.5 + (2*base_hp) + 100) + 10 # assumption that all levels are 100
  catch_rate = (max_hp * capture_rate)/(3 * max_hp)
  shake_prob = ((2**16) - 1) * ((catch_rate/((2**8) - 1))**0.25)
  @capture_flag = true
  4.times {
    random = rand(65535 + 1)
    if random > shake_prob
      @capture_flag = false
      break
    end
  }
  return @capture_flag
end
