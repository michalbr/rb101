MATCH_WIN_SCORE = 5
CARD_RANKS = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack',
              'Queen', 'King', 'Ace']
CARD_SUITS = ['hearts', 'diamonds', 'clubs', 'spades']
NUM_OF_SUITS_IN_DECK = 4
NUM_OF_STARTING_CARDS = 2
MAX_HAND_VAL = 21
DEALERS_MIN_STAY_VALUE = 17
ACE_VAL = 11
K_Q_J_VAL = 10
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
  deck = []

  CARD_RANKS.each do |rank|
    CARD_SUITS.each do |suit|
      card = {}
      card[:rank] = rank
      card[:suit] = suit
      deck << card
    end
  end

  deck
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
  if crd[:rank] == 'Ace'                   then ACE_VAL
  elsif crd[:rank].to_i.to_s == crd[:rank] then crd[:rank].to_i
  else                                     K_Q_J_VAL
  end
end

def calculate_hand_value(hnd)
  hand_value = 0

  hnd.each do |card|
    hand_value += calculate_card_value(card)
  end

  hnd.select { |card| card[:rank] == 'Ace' }.count.times do
    hand_value -= 10 if hand_value > MAX_HAND_VAL
  end

  hand_value
end

def card_name(crd)
  "#{crd[:rank]} of #{crd[:suit]}"
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
  sleep(1)
  card = deal_card(dck)
  prompt("... and it's #{card_name(card)}!")
  sleep(2)

  card
end

def deal_cards_to_player(hand, hand_value, dck)
  loop do
    system 'clear'
    display_hand(hand[:dealer], 'dealer', 'hide 2nd card')
    display_hand(hand[:player], 'player')

    if VALID_HIT.include?(hit_or_stay)
      card = display_dealt_card(dck, 'player')
      hand[:player] << card
      hand_value[:player] = calculate_hand_value(hand[:player])
    else
      break
    end

    break if busted?(hand_value[:player])
  end

  [hand[:player], hand_value[:player]]
end

def busted?(hnd_val)
  hnd_val > MAX_HAND_VAL
end

def players_turn(dck, hand)
  hand_value = {}
  hand[:player] = deal_starting_hand(dck)
  hand_value[:player] = calculate_hand_value(hand[:player])

  hand[:player], hand_value[:player] =
    deal_cards_to_player(hand, hand_value, dck)

  if busted?(hand_value[:player])
    end_round(hand)
  else
    prompt("You chose to stay!")
    sleep(1)
  end

  [hand[:player], hand_value[:player]]
end

def deal_cards_to_dealer(hand, hand_value, dck)
  until hand_value[:dealer] >= DEALERS_MIN_STAY_VALUE
    sleep(2)
    card = display_dealt_card(dck, 'dealer')
    hand[:dealer] << card
    hand_value[:dealer] = calculate_hand_value(hand[:dealer])

    system 'clear'
    display_hand(hand[:dealer], 'dealer')
  end

  [hand[:dealer], hand_value[:dealer]]
end

def dealers_turn(dck, hand)
  prompt("Now it's Dealers turn!")
  sleep(1)
  system 'clear'
  display_hand(hand[:dealer], 'dealer')
  hand_value = {}
  hand_value[:dealer] = calculate_hand_value(hand[:dealer])

  hand[:dealer], hand_value[:dealer] =
    deal_cards_to_dealer(hand, hand_value, dck)

  if busted?(hand_value[:dealer])
    end_round(hand)
  else
    sleep(1)
    prompt("Dealer chose to stay!")
  end

  [hand[:dealer], hand_value[:dealer]]
end

def detect_round_winner(hand)
  hand_value = {}
  hand_value[:player] = calculate_hand_value(hand[:player])
  hand_value[:dealer] = calculate_hand_value(hand[:dealer])

  if hand_value[:player] > MAX_HAND_VAL
    :player_busted
  elsif hand_value[:dealer] > MAX_HAND_VAL
    :dealer_busted
  elsif hand_value[:player] > hand_value[:dealer]
    :player
  elsif hand_value[:player] < hand_value[:dealer]
    :dealer
  else
    :tie
  end
end

def display_round_winner(hand)
  result = detect_round_winner(hand)
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

def end_round(hand)
  sleep(1)
  puts "-------------"
  prompt("Let's comapre hands and see who won ...")
  sleep(1)
  display_hand(hand[:player], 'player')
  display_hand(hand[:dealer], 'dealer')
  sleep(2)
  display_round_winner(hand)
end

def play_round
  deck = initialize_deck
  hand = {}
  hand_value = {}
  hand[:dealer] = deal_starting_hand(deck)

  hand[:player], hand_value[:player] = players_turn(deck, hand)
  unless busted?(hand_value[:player])
    hand[:dealer], hand_value[:dealer] =
      dealers_turn(deck, hand)
    unless busted?(hand_value[:dealer])
      end_round(hand)
    end
  end

  [hand[:player], hand[:dealer]]
end

def update_score(hand, score)
  result = detect_round_winner(hand)
  if result == :dealer_busted || result == :player
    score[:player] += 1
  elsif result == :player_busted || result == :dealer
    score[:dealer] += 1
  end
end

def detect_match_winner(score)
  if score[:player] == MATCH_WIN_SCORE
    return "Player"
  elsif score[:dealer] == MATCH_WIN_SCORE
    return "Dealer"
  end
  nil
end

def match_over?(score)
  !!detect_match_winner(score)
end

def display_match_winner(score)
  prompt "#{detect_match_winner(score)} won the match!"
end

def show_score(score)
  puts "-------------"
  prompt("End of round. Score - Player: #{score[:player]}" \
         " Dealer: #{score[:dealer]}")
end

def play_match
  score = { player: 0, dealer: 0 }
  hand = {}

  loop do
    hand[:player], hand[:dealer] = play_round
    update_score(hand, score)
    show_score(score)

    if match_over?(score)
      display_match_winner(score)
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
