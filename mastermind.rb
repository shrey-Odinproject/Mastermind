# module for displaying stuff
module Display
  def display_intro
    'well play mastermind'
  end

  def display_ask_input
    'enter a 4 digit number with digits ranging from 1-6'
  end

  def display_chances(chance)
    puts "U have #{chance} remaining"
    '----------'
  end

  def display_input_error_msg
    'u can only enter 4 digit number with digits ranging from 1-6 ...'
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
  attr_reader :guess
  
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
  attr_reader :num_of_guesses, :hints
  include Display
  
  def initialize
    @num_of_guesses=12
    @hints=[]
  end

  def won?(comp,player)
    return true if comp.secret_code==player.guess
    false
  end

  def give_hint(comp,player)
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
  
  # 1 round of mastermind
  def play(comp,player)
    while num_of_guesses!=0 || won?
      
    end
  end

end

p1=Player.new
c1=Comp.new
g1=GameLogic.new

c1.generate_code
p1.make_guess(4136)

print p1.guess; print c1.secret_code
puts g1.won?(c1,p1)

print g1.give_hint(c1,p1)