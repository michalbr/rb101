WINNING_COMBINATION = { rock: ['lizard', 'scissors'],
                        paper: ['rock', 'spock'],
                        scissors: ['paper', 'lizard'],
                        spock: ['rock', 'scissors'],
                        lizard: ['spock', 'paper'] }
VALID_CHOICES = { 'rock' => 'r',
                  'paper' => 'p',
                  'scissors' => 'sc',
                  'spock' => 'sp',
                  'lizard' => 'l' }
WINNING_SCORE = 3

welcome_message = <<-MS
 Welcome to Rock Paper Scissors Spock Lizard game!
    Match is played to #{WINNING_SCORE} wins.
    
    You can use shortcuts for typing your choice:
    For rock type 'r' or 'rock',
    paper: 'p' or 'paper',
    scissors: 'sc' or 'scissors',
    spock: 'sp' or 'spock',
    lizard: 'l' or 'lizard'.

MS

def prompt(message)
  puts("=> #{message}")
end

def valid_choice_player?(player_c)
  (VALID_CHOICES.values + VALID_CHOICES.keys)
    .flatten.include?(player_c.downcase)
end

def player_input_to_choice(player_c)
  VALID_CHOICES.select do |k, v|
    v.include?(player_c.downcase) || k.include?(player_c.downcase)
  end.keys[0]
end

def retrieve_player_choice
  choice = ''

  loop do
    prompt("Choose one: #{VALID_CHOICES.keys.join(', ')}")
    choice = gets.chomp

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
  system('clear')
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

  if player_scr == WINNING_SCORE
    prompt("You won the match!")
  elsif computer_scr == WINNING_SCORE
    prompt("Computer won the match!")
  end
end

def play_again?
  prompt("Do you want to play again? (y/n)")
  answer = ''

  loop do
    answer = gets.chomp
    break if ['y', 'n'].include?(answer.downcase)
    prompt("Type 'y' to play again, 'n' to exit.")
  end

  answer.downcase == 'y'
end

def update_score(scr, player_c, computer_c)
  scr[:player] += 1 if win?(player_c, computer_c)
  scr[:computer] += 1 if win?(computer_c, player_c)
end

def play_match
  score = { player: 0, computer: 0 }

  loop do
    player_choice = retrieve_player_choice
    computer_choice = VALID_CHOICES.keys.sample
    display_round_results(player_choice, computer_choice)

    update_score(score, player_choice, computer_choice)
    display_match_results(score[:player], score[:computer])

    break if score.any? { |_, v| v == WINNING_SCORE }
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
