# frozen_string_literal:true

def ask_num_of_guesses
  puts 'enter number guesses u want to give to comp'
  input = gets.chomp
  if check_string(input) && input.to_i <= 20
    return input.to_i
  end

  puts 'invalid input for guess try again ...'
  ask_num_of_guesses
end

# hints is first modified Xs
def hints_adding_Xs_swaszeck(comp_clone, player_clone, hints)
  repeat = true # determines if we repeat 'each' loop from idx 0
  while repeat # whenever X is found array are changed, and 'each' loop is reset and run again from idx =0
    repeat = false
    player_clone.each_with_index do |_elm, idx|
      next unless player_clone[idx] == comp_clone[idx]

      hints.push('X')
      player_clone.delete_at(idx)
      comp_clone.delete_at(idx)
      repeat = true
      break
    end
  end
  [comp_clone, player_clone, hints] # we return 3 things because we have to pass them to 'def hints_adding_Os_swaszeck'
end

# adds Os to hints which only contains Xs until now and  return the complete hint
def hints_adding_Os_swaszeck(comp_clone, player_clone, hints)
  repeat = true # this as done above is to reset iteration after any kind of removal from guess or secret code
  while repeat # reseting iteration ensures bugfree hints and is corrrect implementation of how i envisioned hints func to work
    repeat = false
    comp_clone.each_with_index do |elm, idx| # now to find o we loop over [3,4,1] & [1,0,3] and not the original this ensures correct num of Os
      unless player_clone.include?(elm)
        next
      end # swappeing comp_clone and player_clone in above 2 lines seems to fix bugs fr some secret codes

      hints.push('O')
      player_clone.delete_at(player_clone.index(elm))
      comp_clone.delete_at(idx)
      repeat = true
      break
    end
  end
  hints
end

# gives Xs and Os according to guess
def give_hint_swaszeck(code, guess)
  hints = []
  player_clone = guess.clone # so we dont modify our guess mid way of programm
  comp_clone = code.clone # we use clone because we cant modify original secret code
  only_Xs = hints_adding_Xs_swaszeck(comp_clone, player_clone, hints) # adds only Xs to hints and does some modification
  hints = hints_adding_Os_swaszeck(only_Xs[0], only_Xs[1], only_Xs[2]) # info of Xs is passed to Os to correctly figure out Os
  # then the final hint is store in @hints
  # guess = [] # player guess needs to be reset else on 2nd guess it becomes like [1,2,3,2,4,5,3,1] i.e has 2 guesses in 1
  hints.shuffle! # so u dont know which num are we talking about
end

def make_candidates
  candidates = *(1111..6666)
  candidates.filter! do |nums|
    %w[0 7 8 9].none? { |digit| nums.to_s.include?(digit) }
  end
  candidates.map! { |nums| nums.to_s.chars.map(&:to_i) } # 1234=>[1,2,3,4]
  candidates.shuffle!
end

# takes in secret code and comp then guesses until it wins guarenteed
def swaz(code, chances)
  guess = [1, 1, 2, 2] # default 1st guess
  candidates = make_candidates
  chances.times do # we have confidence well get ans in 5 tries so we dont use a while loop
    puts "Comp have #{chances} chances "
    puts '_______________________'
    puts "comp guessed : #{guess.join}"
    break if guess == code

    hints = give_hint_swaszeck(code, guess)
    puts "hint #{hints.join}"
    candidates.filter! do |candid|
      swaz_hints = give_hint_swaszeck(guess, candid)
      swaz_hints.sort == hints.sort # this was causing error cause we shuffled hints so [O,X] != [X,O] but we want that so we sort
    end
    guess = candidates.pop
    chances -= 1
  end
  puts guess == code ? 'Comp Won!!' : 'out of turns Comp Lost!!'
end
