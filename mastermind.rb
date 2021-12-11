# module for displaying stuff
module Display
  def display_intro_code_breaker
    puts 'We are playing mastermind and u are the code breaker'
  end

  def display_intro_code_maker
    puts 'We are playing mastermind and u are the code maker'
  end

  def display_create_secret_code
    puts 'Create a code with 4 digit number with digits ranging from 1-6'
  end

  def display_choose_game
    puts 'press 1 : code breaker'
    puts 'press 2 : code maker'
  end

  def display_ask_input
    puts 'enter a 4 digit number with digits ranging from 1-6'
  end

  def display_chances(chance)
    puts "U have #{chance} chances remaining"
    puts '----------'
  end

  def display_input_error_msg
    puts 'u can only enter 4 digit number with digits ranging from 1-6 ...'
  end

  def display_hint_info
    puts 'X is for correct guess in correct position'
    puts 'O is for correct guess in wrong position'
  end

  def display_input_guess_count
    puts 'how many guesses u want ? ideally it should be 12, max is 20 :'
  end

  def display_random_guess(guess)
    puts "comp guessed : #{guess}"
  end

  # return 1 or 2
  def display_ask_game_choice
    display_choose_game
    choice = gets.chomp
    return choice if choice == '1' || choice == '2'

    puts 'erronous input !!!'
    display_ask_game_choice
  end
end

# comp class that holds secret code
class Comp
  attr_accessor :secret_code, :guess

  def initialize
    @secret_code = []
    @guess = []
  end

  def make_random_guess
    guess.push(rand(1..6)) while guess.length < 4
  end

  def generate_code
    secret_code.push(rand(1..6)) while secret_code.length < 4
  end
end

# the player of game
class Player < Comp
  attr_accessor :guess, :secret_code

  # as now both player and comp now have guess and secret code a seprate initialize is not needed

  def make_code(num)
    while num != 0
      a = num % 10
      secret_code.push(a)
      num /= 10
    end
    secret_code.reverse!
  end

  # player will type a number and it will be passed to this method
  def make_guess(num)
    # 1256 is converted to [1,2,5,6]
    while num != 0
      a = num % 10
      guess.push(a)
      num /= 10
    end
    guess.reverse!
  end
end

# class to dictate game flow and stores all logic
class GameLogic
  attr_accessor :num_of_guesses, :hints
  attr_reader :game_mode

  include Display

  def initialize(mode)
    @num_of_guesses = nil # will be descided by user
    @hints = []
    @game_mode = mode
  end

  def win?(comp, player)
    return true if comp.secret_code == player.guess

    false
  end

  # gives Xs and Os according to guess
  def give_hint(comp, player)
    @hints = []
    player_mod = player.guess.clone # so we dont modify our guess mid way of programm
    comp_mod = comp.secret_code.clone # we use clone because we cant modify original secret code
    repeat = true # determines if we repeat 'each' loop from idx 0
    while repeat # whenever X is found array are changed and each loop is reset and run again from idx =0
      repeat = false
      player_mod.each_with_index do |_elm, idx|
        if player_mod[idx] == comp_mod[idx] # we check for Xs and remove both same elements from both arrays
          # eg [1,1,0,3]sec [3,1,4,1]guess so they become [1,0,3] & [3,4,1] and hints=[X]
          hints.push('X')
          player_mod.delete_at(idx)
          comp_mod.delete_at(idx)
          repeat = true
          break
        end
      end
    end

    repeat = true # this as done above is to reset iteration after any kind of removal from guess or secret code
    while repeat # reseting iteration ensures bugfree hints and is corrrect implementation of how i envisioned hints func to work
      repeat = false
      comp_mod.each_with_index do |elm, idx| # now to find o we loop over [3,4,1] & [1,0,3] and not the original this enures correct num of Os
        if player_mod.include?(elm) # swappeing comp_mod and player_mod in above 2 lines seems to fix bugs fr some secret codes
          hints.push('O')
          player_mod.delete_at(player_mod.index(elm)) # removes only 1st occurence of duplicate and not all duplicates
          # these changes were made looking at case code=1122, guess=3324, hint was OO instead of correct hint O
          # if no while to reset then sec=1122, guess=2211 we got OO instead of correct OOOO
          comp_mod.delete_at(idx)
          repeat = true
          break
        end
      end
    end

    player.guess = [] # player guess needs to be reset else on 2nd guess it becomes like [1,2,3,2,4,5,3,1] i.e has 2 guesses in 1
    hints.shuffle # so u dont know which num are we talking about
  end

  # It would be truthy if string contains only digits or if it is an empty string. Otherwise returns false.
  def check_string(string)
    string.scan(/\D/).empty?
  end

  def ask_guess_count
    display_input_guess_count
    input = gets.chomp
    if check_string(input) && input.to_i <= 20
      return self.num_of_guesses = input.to_i
    end

    puts 'invalid input for guess try again ...'
    ask_guess_count
  end

  # checks and gets input from user
  def get_input(player)
    while true
      display_ask_input
      input = gets.chomp
      if input.length != 4 || !check_string(input) || input.include?('0')
        display_input_error_msg
      else
        player.make_guess(input.to_i)
        break
      end
    end
  end

  # 1 round of mastermind as code breaker
  def play_code_breaker
    display_intro_code_breaker
    display_hint_info
    ask_guess_count
    display_chances(num_of_guesses)
    player = Player.new
    comp = Comp.new
    comp.generate_code
    while num_of_guesses != 0 || !win?
      get_input(player)
      if win?(comp, player) # u win
        puts 'Victory!! '
        break
      end
      self.num_of_guesses -= 1
      puts "hint: #{give_hint(comp, player).join}"
      display_chances(num_of_guesses)
      if num_of_guesses == 0 # u lost
        puts "ans was #{comp.secret_code}"
        break
      end
    end
    puts 'game over'
  end

  # 1 round of mastermind as code maker
  # swapped player and comp positions in arguments so roles are switched
  def play_code_maker
    player = Player.new
    comp = Comp.new
    display_intro_code_maker
    display_create_secret_code
    secret_code_made = gets.chomp.to_i
    player.make_code(secret_code_made)
    ask_guess_count
    display_chances(num_of_guesses)
    while num_of_guesses != 0 || !win?
      comp.make_random_guess
      display_random_guess(comp.guess)
      if win?(player, comp) # u win
        puts 'Victory!! '
        break
      end
      self.num_of_guesses -= 1
      puts "hint: #{give_hint(player, comp).join}"
      display_chances(num_of_guesses)
      if num_of_guesses == 0 # u lost
        puts "ans was #{player.secret_code}"
        break
      end
    end
  end
end

# replaybility
def play_game
  include Display
  choice = display_ask_game_choice # as this method is a display method
  game = GameLogic.new(choice)
  choice == '1' ? game.play_code_breaker : game.play_code_maker
  repeat_game
end

def repeat_game
  puts "Would you like to play a new game? Press 'y' for yes or 'n' for no."
  repeat_input = gets.chomp.downcase
  if repeat_input == 'y'
    play_game
  else
    puts 'Thanks for playing!'
  end
end

play_game
