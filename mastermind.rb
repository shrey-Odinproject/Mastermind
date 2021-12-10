require 'pry-byebug'

# module for displaying stuff
module Display
  def display_intro
    puts 'We are playing mastermind'
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
end

# comp class that holds secret code
class Comp
  attr_reader :secret_code

  def initialize
    @secret_code = []
  end

  def generate_code
    secret_code.push(rand(1..6)) while secret_code.length < 4
  end
end

# the player of game
class Player
  attr_accessor :guess

  def initialize
    @guess = []
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

  include Display

  def initialize
    @num_of_guesses = 1
    @hints = []
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

    player_mod.each do |elm| # now to find o we loop over [3,4,1] & [1,0,3] and not the original this enures correct num of Os
      hints.push('O') if comp_mod.include?(elm)
    end
    player.guess = [] # player guess needs to be reset else on 2nd guess it becomes like [1,2,3,2,4,5,3,1] i.e has 2 guesses in 1
    hints.shuffle # so u dont know which num are we talking about
  end

  # It would be truthy if string contains only digits or if it is an empty string. Otherwise returns false.
  def check_string(string)
    string.scan(/\D/).empty?
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

  # 1 round of mastermind
  def play
    display_intro
    display_hint_info
    display_chances(num_of_guesses)
    player = Player.new
    comp = Comp.new
    comp.generate_code
    # puts "ans was #{comp.secret_code}"
    # binding.pry
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
end

# replaybility
def play_game
  game = GameLogic.new
  game.play
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
