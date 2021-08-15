VALID_CHOICES = %w(rock paper scissors spock lizard)
WINNING_COMBINATION = { rock: ['lizard', 'scissors'],
                        paper: ['rock', 'spock'],
                        scissors: ['paper', 'lizard'],
                        spock: ['rock', 'scissors'],
                        lizard: ['spock', 'paper'] }
VALID_CHOICES_PLAYER = { rock: ['r', 'rock'],
                         paper: ['p', 'paper'],
                         scissors: ['sc', 'scissors'],
                         spock: ['sp', 'spock'],
                         lizard: ['l', 'lizard'] }

welcome_message = <<-MS
 Welcome to Rock Paper Scissors Spock Lizard game!
    Match is played to 3 wins.
    
    You can use shortcuts for typing your choice:
    For rock type 'r' or 'rock',
    paper: 'p' or 'paper',
    scissors: 'sc' or 'scissors',
    spock: 'sp' or 'spock',
    lizard: 'l' or 'lizard'.

MS

def prompt(message)
  Kernel.puts("=> #{message}")
end

def valid_choice_player?(player_c)
  VALID_CHOICES_PLAYER.values.flatten.include?(player_c.downcase)
end

def player_input_to_choice(player_c)
  VALID_CHOICES_PLAYER.select { |_, v| v.include?(player_c.downcase) }
                      .keys[0].to_s
end

def retrieve_player_choice
  choice = ''

  loop do
    prompt("Choose one: #{VALID_CHOICES.join(', ')}")
    choice = Kernel.gets().chomp()

    if valid_choice_player?(choice)
      choice = player_input_to_choice(choice)
      break
    elsif choice.downcase == 's'
      prompt("Did you mean (sc)issors or (sp)ock?")
    else
      prompt("That's not a valid choice")
    end
  end

  choice
end

def win?(first, second)
  WINNING_COMBINATION[first.to_sym].include?(second)
end

def display_round_results(player, computer)
  prompt("You chose: #{player}; Computer chose: #{computer}")

  if win?(player, computer)
    prompt('You won!')
  elsif win?(computer, player)
    prompt("Computer won!")
  else
    prompt("It's a tie!")
  end
end

def display_match_results(player_scr, computer_scr)
  prompt("Score - You: #{player_scr}  Computer: #{computer_scr}")

  if player_scr == 3
    prompt("You won the match!")
  elsif computer_scr == 3
    prompt("Computer won the match!")
  end
end

def play_again?
  prompt("Do you want to play again? (y/n)")
  answer = ''

  loop do
    answer = Kernel.gets().chomp()
    break if ['y', 'n'].include?(answer.downcase)
    prompt("Type 'y' to play again, 'n' to exit.")
  end

  answer == 'y'
end

def play_match
  player_score = 0
  computer_score = 0

  loop do
    player_choice = retrieve_player_choice
    computer_choice = VALID_CHOICES.sample
    display_round_results(player_choice, computer_choice)

    player_score += 1 if win?(player_choice, computer_choice)
    computer_score += 1 if win?(computer_choice, player_choice)
    display_match_results(player_score, computer_score)

    break if player_score == 3 || computer_score == 3
  end
end

system('clear')
prompt(welcome_message)

loop do
  play_match

  break unless play_again?
  system('clear')
end

prompt('Thank you for playing. Good bye!')
