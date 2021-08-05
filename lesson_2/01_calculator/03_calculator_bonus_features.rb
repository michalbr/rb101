require 'pry'
require 'yaml'
MESSAGES = YAML.load_file('calculator_messages.yml')

def prompt(message)
  Kernel.puts("=> #{message}")
end

def valid_number?(num)
  (Integer(num) rescue false) || (Float(num) rescue false)
end

prompt(MESSAGES['choose_language'])

language = ''
loop do
  language = Kernel.gets().chomp().downcase()

  if %w(en pl).include?(language)
    break
  else
    prompt(MESSAGES['invalid_language'])
  end
end

LANGUAGE = language

def operation_to_message(op)
  word =  case op
          when '1'
            MESSAGES[LANGUAGE]['add']
          when '2'
            MESSAGES[LANGUAGE]['subtract']
          when '3'
            MESSAGES[LANGUAGE]['multiply']
          when '4'
            MESSAGES[LANGUAGE]['divide']
          end
  word
end

prompt(MESSAGES[language]['welcome'])

name = ''
loop do
  name = Kernel.gets().chomp()

  if name.empty?
    prompt(MESSAGES[language]['valid_name'])
  else
    break
  end
end

prompt(MESSAGES[language]['hi'] + " #{name}")

loop do # main loop
  number1 = ''
  loop do
    prompt(MESSAGES[language]['number1'])
    number1 = Kernel.gets().chomp()

    if valid_number?(number1)
      break
    else
      prompt(MESSAGES[language]['invalid_number'])
    end
  end

  number2 = nil
  loop do
    prompt(MESSAGES[language]['number2'])
    number2 = Kernel.gets().chomp()

    if valid_number?(number2)
      break
    else
      prompt(MESSAGES[language]['invalid_number'])
    end
  end

  prompt(MESSAGES[language]['operator_prompt'])

  operator = ''
  loop do
    operator = Kernel.gets().chomp()

    if %w(1 2 3 4).include?(operator)
      break
    else
      prompt(MESSAGES[language]['invlaid_operator'])
    end
  end

  prompt("#{operation_to_message(operator)} " + MESSAGES[language]['performed_operation'])

  result = case operator
           when '1'
             number1.to_i() + number2.to_i()
           when '2'
             number1.to_i() - number2.to_i()
           when '3'
             number1.to_i() * number2.to_i()
           when '4'
             number1.to_f() / number2.to_f()
           end

  prompt(MESSAGES[language]['result'] + " #{result}")

  prompt(MESSAGES[language]['another_calc'])
  answer = Kernel.gets().chomp()
  break unless answer.downcase().start_with?(MESSAGES[language]['another_calc_yes'])
end

prompt(MESSAGES[language]['goodbye'])
