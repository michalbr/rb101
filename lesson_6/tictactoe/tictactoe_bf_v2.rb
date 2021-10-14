INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
VALID_YES_NO = ['y', 'n']
VALID_PLAYER_COMPUTER = ['p', 'c']
MID_SQUARE = 5
LINE_SIZE = 3
WINNING_SCORE = 5
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                [[1, 5, 9], [3, 5, 7]]

def welcome_message
  prompt <<~MS
    Welcome to Tic Tac Toe game!
       Match is played to #{WINNING_SCORE} wins.
       Press "Enter" to start first round!
  MS
  gets
end

def prompt(msg)
  puts "=> #{msg}"
end

def decide_who_goes_first?
  answer = ''

  loop do
    prompt "Do you want to decide who makes first move? (y or n)"
    answer = gets.chomp.downcase
    break if VALID_YES_NO.include?(answer)
    prompt "Input seems to be incorrect. Choose 'y' if you want to decide " \
           "who makes first move,\n 'n' otherwise."
  end

  answer == 'y'
end

def who_goes_first
  answer = ''

  if decide_who_goes_first?
    loop do
      prompt "Who should start first? (P)layer or (C)omputer?"
      answer = gets.chomp.downcase
      break if VALID_PLAYER_COMPUTER.include?(answer)
      prompt "Input seems to be incorrect. Choose 'p' for player, " \
             "'c' for computer."
    end
  else
    answer = VALID_PLAYER_COMPUTER.sample
  end

  answer
end

# rubocop:disable Metrics/AbcSize
def display_board(brd)
  system 'clear'
  puts "You're a #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}."
  puts ""
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
  puts ""
end
# rubocop:enable Metrics/AbcSize

def initialize_board
  new_board = {}

  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def joinor(arr, separator = ', ', join_word = 'or')
  arr.map!(&:to_s)

  case arr.size
  when 0 then ''
  when 1 then arr[0]
  when 2 then arr[0] + ' ' + join_word + ' ' + arr[1]
  else        arr[0..-2].join(separator) + separator +
    join_word + ' ' + arr[-1]
  end
end

def integer?(num)
  num.to_i.to_s == num
end

def player_places_piece!(brd)
  square = ''

  loop do
    prompt "Choose a position to place a piece: #{joinor(empty_squares(brd))}:"
    square = gets.chomp
    break if empty_squares(brd).include?(square.to_i) && integer?(square)
    prompt("Sorry, that's not a valid choice")
  end

  brd[square.to_i] = PLAYER_MARKER
end

def find_at_risk_square(line, brd, marker)
  if brd.values_at(*line).count(marker) == 2
    line.each do |piece|
      if brd[piece] == INITIAL_MARKER
        return piece
      end
    end
  end
  ''
end

# Cyclomatic complexity was [8/7]. Decided to ignore this offense.
# rubocop:disable Metrics/CyclomaticComplexity
def computer_places_piece!(brd)
  square = ''
  WINNING_LINES.each do |line|
    square = find_at_risk_square(line, brd, COMPUTER_MARKER)
    break if square != ''
  end

  if square == ''
    WINNING_LINES.each do |line|
      square = find_at_risk_square(line, brd, PLAYER_MARKER)
      break if square != ''
    end
  end

  square = MID_SQUARE if empty_squares(brd).include?(MID_SQUARE)
  square = empty_squares(brd).sample if square == ''
  brd[square] = COMPUTER_MARKER
end
# rubocop:enable Metrics/CyclomaticComplexity

def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def place_piece!(brd, current_plr)
  current_plr == 'p' ? player_places_piece!(brd) : computer_places_piece!(brd)
end

def alternate_player(current_plr)
  current_plr == 'p' ? 'c' : 'p'
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == LINE_SIZE
      return "Player"
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == LINE_SIZE
      return "Computer"
    end
  end
  nil
end

def display_winner(brd)
  if someone_won?(brd)
    prompt "#{detect_winner(brd)} won match!"
  else
    prompt "It's a tie"
  end
end

def play_round(brd)
  display_board(brd)
  # assumed that we choose starter for every round
  current_player = who_goes_first

  loop do
    display_board(brd)
    place_piece!(brd, current_player)
    current_player = alternate_player(current_player)
    break if someone_won?(brd) || board_full?(brd)
  end

  display_board(brd)
  display_winner(brd)
end

def update_score(scr, brd)
  scr[:player] += 1 if detect_winner(brd) == "Player"
  scr[:computer] += 1 if detect_winner(brd) == "Computer"
end

def detect_game_winner(player_scr, computer_scr)
  if player_scr == WINNING_SCORE
    return "Player"
  elsif computer_scr == WINNING_SCORE
    return "Computer"
  end
  nil
end

def game_over?(player_scr, computer_scr)
  !!detect_game_winner(player_scr, computer_scr)
end

def display_game_winner(player_scr, computer_scr)
    prompt "#{detect_game_winner(player_scr, computer_scr)} won the game!"
end

def start_next_round
  prompt "Press \"Enter\" to start next round!"
  gets
end

def play_again?
  answer = ''

  loop do
    prompt "Play again? (y or n)"
    answer = gets.chomp.downcase
    break if VALID_YES_NO.include?(answer)
    prompt "Input seems to be incorrect. " \
      "Choose 'y' to play again, 'n' to exit the game."
  end

  answer == 'y'
end

def play_game
  score = { player: 0, computer: 0 }

  loop do
    board = initialize_board
    play_round(board)

    update_score(score, board)
    prompt("Score - Player: #{score[:player]} Computer: #{score[:computer]}")

    if game_over?(score[:player], score[:computer])
      display_game_winner(score[:player], score[:computer])
      break
    end

    start_next_round
  end
end

system 'clear'
welcome_message

loop do
  play_game
  break unless play_again?
  system 'clear'
end

prompt "Thanks for playing Tic Tac Toe! Good Bye!"
