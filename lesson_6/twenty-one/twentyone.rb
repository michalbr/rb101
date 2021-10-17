MATCH_WIN_SCORE = 5
CARD_RANKS = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack',
              'Queen', 'King', 'Ace']
CARD_SUITS = ['hearts', 'diamonds', 'clubs', 'spades']
NUM_OF_SUITS_IN_DECK = 4
NUM_OF_STARTING_CARDS = 2
MAX_HAND_VAL = 21
DEALERS_MIN_STAY_VALUE = 17
VALID_HIT = ['h', 'hit']
VALID_STAY = ['s', 'stay']

def prompt(msg)
  puts "=> #{msg}"
end

# rubocop:disable Metrics/MethodLength
def display_welcome_msg
  prompt <<~MS
    Welcome to Twenty-One game!
       The goal of Twenty-One is to try to get as close to 21 as possible,
       without going over. If you go over 21, it's a "bust" and you lose.
       
       You play against dealer and both of you are initially dealt 2 cards.
       You can see your cards, but you can only see one of the dealer's cards.
       
       Card values:
       2 - 10 => face value
       jack, queen, king => 10
       ace => 1 or 11
       An ace counts as 11 unless your hand value exceeds 21, in which case
       it counts as 1 instead.
       
       You can decide to "hit" which means you will get another card. You can
       "hit" as many times as you want. If you decide to "stay", then it's
       dealer's turn.
       
       When both you and the dealer stay, it's time to compare the total value
       of the cards and see who won.
       
       Game is played to #{MATCH_WIN_SCORE} won rounds.
       
       Let's play Twenty-One! Ready to go?
       
       Press "Enter" to start!
  MS
  gets
end
# rubocop:enable Metrics/MethodLength

def initialize_deck
  CARD_RANKS.product(CARD_SUITS)
end

def remove_dealt_card_from_deck(dlt_crd, dck)
  dck.delete(dlt_crd)
end

def deal_card(dck)
  dealt_card = dck.sample
  remove_dealt_card_from_deck(dealt_card, dck)
  dealt_card
end

def deal_starting_hand(dck)
  starting_cards = []

  NUM_OF_STARTING_CARDS.times do
    starting_cards << deal_card(dck)
  end

  starting_cards
end

def hit_or_stay
  answer = ''

  loop do
    prompt("(H)it or (s)tay?")
    answer = gets.chomp.downcase
    break if (VALID_HIT + VALID_STAY).include?(answer)
    prompt("Incorrect input. Type 'h' or 'hit' to get another card, 's' or " \
           "'stay' to stay.")
  end

  answer
end

def calculate_card_value(crd)
  if crd[0] == 'Ace'               then 11
  elsif crd[0].to_i.to_s == crd[0] then crd[0].to_i
  else                                  10
  end
end

def calculate_hand_value(hnd)
  hand_value = 0

  hnd.each do |card|
    hand_value += calculate_card_value(card)
  end

  hnd.select { |card| card[0] == 'Ace' }.count.times do
    hand_value -= 10 if hand_value > MAX_HAND_VAL
  end

  hand_value
end

def card_name(crd)
  "#{crd[0]} of #{crd[1]}"
end

def join_card_names(hnd)
  card_names = hnd.map { |card| card_name(card) }

  if card_names.size == 2
    card_names.join(' and ')
  else
    [card_names[0..-2].join(', '), card_names[-1]].join(' and ')
  end
end

def display_hand(hnd, whos_hnd, hide_2nd_crd = false)
  if whos_hnd.downcase == 'dealer' && hide_2nd_crd
    prompt "Dealer has: #{card_name(hnd[0])} and unknown card"
  elsif whos_hnd.downcase == 'dealer'
    prompt "Dealer has: #{join_card_names(hnd)}" \
           " (hand value is #{calculate_hand_value(hnd)})"
  elsif whos_hnd.downcase == 'player'
    prompt "You have: #{join_card_names(hnd)}" \
           " (hand value is #{calculate_hand_value(hnd)})"
  end
end

def display_dealt_card(dck, whos_card)
  participant = case whos_card.downcase
                when 'player' then 'You'
                when 'dealer' then 'Dealer'
                end

  prompt("#{participant} chose to get another card ...")
  sleep(2)
  card = deal_card(dck)
  prompt("... and it's #{card_name(card)}!")
  sleep(3)

  card
end

def deal_cards_to_player(plrs_hnd, plrs_hnd_val, dck, dlrs_hnd)
  loop do
    system 'clear'
    display_hand(dlrs_hnd, 'dealer', 'hide 2nd card')
    display_hand(plrs_hnd, 'player')

    if VALID_HIT.include?(hit_or_stay)
      card = display_dealt_card(dck, 'player')
      plrs_hnd << card
      plrs_hnd_val = calculate_hand_value(plrs_hnd)
    else
      break
    end

    break if busted?(plrs_hnd_val)
  end

  [plrs_hnd, plrs_hnd_val]
end

def busted?(hnd_val)
  hnd_val > MAX_HAND_VAL
end

def players_turn(dck, dlrs_hnd)
  players_hand = deal_starting_hand(dck)
  players_hand_value = calculate_hand_value(players_hand)

  players_hand, players_hand_value =
    deal_cards_to_player(players_hand, players_hand_value, dck, dlrs_hnd)

  if busted?(players_hand_value)
    end_round(players_hand, dlrs_hnd)
  else
    prompt("You chose to stay!")
    sleep(2)
  end

  [players_hand, players_hand_value]
end

def deal_cards_to_dealer(dlrs_hnd, dlrs_hnd_val, dck)
  until dlrs_hnd_val >= DEALERS_MIN_STAY_VALUE
    sleep(3)
    card = display_dealt_card(dck, 'dealer')
    dlrs_hnd << card
    dlrs_hnd_val = calculate_hand_value(dlrs_hnd)

    system 'clear'
    display_hand(dlrs_hnd, 'dealer')
  end

  [dlrs_hnd, dlrs_hnd_val]
end

def dealers_turn(dck, dlrs_hnd, plrs_hnd)
  prompt("Now it's Dealers turn!")
  sleep(2)
  system 'clear'
  display_hand(dlrs_hnd, 'dealer')
  dealers_hand_value = calculate_hand_value(dlrs_hnd)

  dlrs_hnd, dealers_hand_value =
    deal_cards_to_dealer(dlrs_hnd, dealers_hand_value, dck)

  if busted?(dealers_hand_value)
    end_round(plrs_hnd, dlrs_hnd)
  else
    sleep(2)
    prompt("Dealer chose to stay!")
  end

  [dlrs_hnd, dealers_hand_value]
end

def detect_round_winner(plrs_hnd, dlrs_hnd)
  plrs_hnd_val = calculate_hand_value(plrs_hnd)
  dlrs_hnd_val = calculate_hand_value(dlrs_hnd)

  if plrs_hnd_val > MAX_HAND_VAL
    :player_busted
  elsif dlrs_hnd_val > MAX_HAND_VAL
    :dealer_busted
  elsif plrs_hnd_val > dlrs_hnd_val
    :player
  elsif plrs_hnd_val < dlrs_hnd_val
    :dealer
  else
    :tie
  end
end

def display_round_winner(plrs_hnd, dlrs_hnd)
  result = detect_round_winner(plrs_hnd, dlrs_hnd)
  case result
  when :player_busted
    prompt "You've been busted! Dealer won the game!"
  when :dealer_busted
    prompt "Dealer has been busted! You won the game!"
  when :player
    prompt "You win!"
  when :dealer
    prompt "Dealer wins!"
  when :tie
    prompt "It's a tie!"
  end
end

def end_round(plrs_hnd, dlrs_hnd)
  sleep(2)
  puts "-------------"
  prompt("Let's comapre hands and see who won ...")
  sleep(2)
  display_hand(plrs_hnd, 'player')
  display_hand(dlrs_hnd, 'dealer')
  sleep(3)
  display_round_winner(plrs_hnd, dlrs_hnd)
end

def play_round
  deck = initialize_deck
  dealers_hand = deal_starting_hand(deck)

  players_hand, players_hand_value = players_turn(deck, dealers_hand)
  unless busted?(players_hand_value)
    dealers_hand, dealers_hand_value =
      dealers_turn(deck, dealers_hand, players_hand)
    unless busted?(dealers_hand_value)
      end_round(players_hand, dealers_hand)
    end
  end

  [players_hand, dealers_hand]
end

def update_score(plrs_hnd, dlrs_hnd, scr)
  result = detect_round_winner(plrs_hnd, dlrs_hnd)
  if result == :dealer_busted || result == :player
    scr[:player_score] += 1
  elsif result == :player_busted || result == :dealer
    scr[:dealer_score] += 1
  end
end

def detect_match_winner(plr_scr, dlr_scr)
  if plr_scr == MATCH_WIN_SCORE
    return "Player"
  elsif dlr_scr == MATCH_WIN_SCORE
    return "Dealer"
  end
  nil
end

def match_over?(plr_scr, dlr_scr)
  !!detect_match_winner(plr_scr, dlr_scr)
end

def display_match_winner(plr_scr, dlr_scr)
  prompt "#{detect_match_winner(plr_scr, dlr_scr)} won the match!"
end

def play_match
  score = { player_score: 0, dealer_score: 0 }

  loop do
    players_hand, dealers_hand = play_round
    update_score(players_hand, dealers_hand, score)
    puts "-------------"
    prompt("End of round. Score - Player: #{score[:player_score]}" \
           " Dealer: #{score[:dealer_score]}")

    if match_over?(score[:player_score], score[:dealer_score])
      display_match_winner(score[:player_score], score[:dealer_score])
      break
    end

    prompt("Press \"Enter\" to continue")
    gets
  end
end

def play_again?
  answer = ''

  puts "-------------"
  loop do
    prompt "Play again? (y or n)"
    answer = gets.chomp.downcase
    break if ['y', 'n'].include?(answer)
    prompt "Input seems to be incorrect. " \
      "Choose 'y' to play again, 'n' to exit the game."
  end

  answer == 'y'
end

system 'clear'
display_welcome_msg

loop do
  play_match
  break unless play_again?
end
