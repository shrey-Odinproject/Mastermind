# module for displaying stuff
require 'pry-byebug'
module Display
  def display_intro
    puts'well play mastermind'
  end

  def display_ask_input
    puts'enter a 4 digit number with digits ranging from 1-6'
  end

  def display_chances(chance)
    puts "U have #{chance} chances remaining"
    '----------'
  end

  def display_input_error_msg
    puts'u can only enter 4 digit number with digits ranging from 1-6 ...'
  end

  def display_hint_info
    puts 'X is for correct guess in correct position'
    puts 'O is for correct guess in wrong position'
  end
end

class Comp
  attr_reader :secret_code
  
  def initialize
    @secret_code=[]
  end
  
  def generate_code
    while secret_code.length<4
      secret_code.push(rand(1..6))
    end
  end
end

class Player
  attr_accessor :guess
  
  def initialize
    @guess=[]
  end

  # player will type a number and it will be passed to this method
  def make_guess(num) 
    while num!=0 do 
      a=num%10
      guess.push(a)
      num=num/10
    end
    guess.reverse!
  end
end

class GameLogic
  attr_accessor :num_of_guesses, :hints
  include Display
  
  def initialize
    @num_of_guesses=3
    @hints=[]
  end

  def win?(comp,player)
    return true if comp.secret_code==player.guess
    false
  end

  def give_hint(comp,player)
    @hints=[]
    player.guess.each_with_index do |elm,idx|
      if comp.secret_code.include?(elm)
        if comp.secret_code[idx]==player.guess[idx]
          hints.push("X")
        else
          hints.push("O")
        end
      end
    end
    hints.shuffle
  end
  
  # It would be truthy if string contains only digits or if it is an empty string. Otherwise returns false.
  def check_string(string)
    string.scan(/\D/).empty?
  end
  
  def get_input(player)
    while true
      display_ask_input
      input=gets.chomp
      if input.length!=4 || !check_string(input)
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
    player=Player.new
    comp=Comp.new
    comp.generate_code
    #puts "ans was #{comp.secret_code}"
    #binding.pry
    while num_of_guesses!=0 || !win?
      get_input(player)
      if win?(comp,player)
        puts 'u won'
        break
      end
      self.num_of_guesses-=1
      p give_hint(comp,player)
      player.guess=[] # player guess needs to be set to empty else on 2nd guess it becomes like [1,2,3,2,4,5,3,1] i.e has 2 guesses in 1
      display_chances(num_of_guesses)
      if num_of_guesses==0
        puts "ans was #{comp.secret_code}"
        break
      end
    end
    puts 'game over'
  end
end
=begin
p1=Player.new
c1=Comp.new
g1=GameLogic.new

c1.generate_code
p1.make_guess(4136)

print p1.guess; print c1.secret_code
puts g1.win?(c1,p1)

print g1.give_hint(c1,p1)
=end
game=GameLogic.new
game.play