require 'pry'
require 'yaml'
MESSAGES = YAML.load_file('car_loan_calculator_messages.yml')

def prompt(message)
  puts "=> #{message}"
end

def valid_float_or_integer?(num)
  (num.to_f.to_s == num || num.to_i.to_s == num) && num.to_f > 0
end

prompt(MESSAGES['welcome'])
loop do
  prompt(MESSAGES['enter_loan_amount'])
  loan_amount = ''
  loop do
    loan_amount = gets.chomp
    if valid_float_or_integer?(loan_amount)
      break
    else
      prompt(MESSAGES['loan_amount_incorrect'])
    end
  end
  loan_amount = loan_amount.to_f

  prompt(MESSAGES['enter_apr'])
  annual_percentage_rate = ''
  loop do
    annual_percentage_rate = gets.chomp
    if valid_float_or_integer?(annual_percentage_rate)
      break
    else
      prompt(MESSAGES['apr_incorrect'])
    end
  end
  annual_percentage_rate = annual_percentage_rate.to_f

  prompt(MESSAGES['enter_loan_duration'])
  loan_duration_in_years = ''
  loop do
    loan_duration_in_years = gets.chomp
    if valid_float_or_integer?(loan_duration_in_years)
      break
    else
      prompt(MESSAGES['loan_duration_incorrect'])
    end
  end
  loan_duration_in_years = loan_duration_in_years.to_i

  loan_duration_in_months = loan_duration_in_years * 12
  monthly_interest_rate = annual_percentage_rate / 12 / 100
  monthly_payment =
    (loan_amount * (monthly_interest_rate /
    (1 - (1 + monthly_interest_rate)**(-loan_duration_in_months)))).round(2)
  total_payment = (loan_duration_in_months * monthly_payment).round(2)
  total_interest = (total_payment - loan_amount).round(2)

  prompt(format(MESSAGES["result"],
                monthly_payment: monthly_payment,
                loan_duration_in_months: loan_duration_in_months,
                total_payment: total_payment,
                total_interest: total_interest))
  prompt(MESSAGES['another_calc'])
  calculate_again = gets.chomp
  break unless calculate_again.downcase == 'y'
end

prompt(MESSAGES['exit'])
