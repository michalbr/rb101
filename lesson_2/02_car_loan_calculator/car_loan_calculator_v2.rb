require 'yaml'
MESSAGES = YAML.load_file('car_loan_calculator_messages_v2.yml')

def prompt(message)
  puts "=> #{message}"
end

def valid_float_or_integer?(num)
  (num.to_f.to_s == num || num.to_i.to_s == num) && num.to_f > 0
end

def valid_zero_float_or_integer?(num)
  (num.to_f.to_s == num || num.to_i.to_s == num) && num.to_f == 0
end

def valid_integer?(num)
  num.to_i.to_s == num && num.to_f > 0
end

def retrieve_loan_amount
  prompt(MESSAGES['enter_loan_amount'])
  loan_amount = ''

  loop do
    loan_amount = gets.chomp
    break if valid_float_or_integer?(loan_amount)
    prompt(MESSAGES['loan_amount_incorrect'])
  end

  loan_amount.to_f
end

def retrieve_annual_percentage_rate
  prompt(MESSAGES['enter_apr'])
  annual_percentage_rate = ''

  loop do
    annual_percentage_rate = gets.chomp
    break if valid_float_or_integer?(annual_percentage_rate)
    break if valid_zero_float_or_integer?(annual_percentage_rate)
    prompt(MESSAGES['apr_incorrect'])
  end

  annual_percentage_rate.to_f
end

def retrieve_loan_duration
  prompt(MESSAGES['enter_loan_duration'])
  loan_duration_in_years = ''

  loop do
    loan_duration_in_years = gets.chomp
    break if valid_integer?(loan_duration_in_years)
    prompt(MESSAGES['loan_duration_incorrect'])
  end

  loan_duration_in_years.to_i
end

def calculate_monthly_payment(mth_int_r, loan_amt, loan_dur_mth)
  if mth_int_r == 0
    (loan_amt / loan_dur_mth).round(2)
  else
    (loan_amt * (mth_int_r / (1 - (1 + mth_int_r)**(-loan_dur_mth)))).round(2)
  end
end

def calculate_total_payment(mth_int_r, loan_amt, loan_dur_mth, mth_pmt)
  if mth_int_r == 0
    loan_amt.round(2)
  else
    (loan_dur_mth * mth_pmt).round(2)
  end
end

def calculate_total_interest(tot_pmt, loan_amt)
  (tot_pmt - loan_amt).round(2)
end

def calculate_loan_parameters
  loan_amount = retrieve_loan_amount
  monthly_interest_rate = retrieve_annual_percentage_rate / 12 / 100
  loan_duration_in_months = retrieve_loan_duration * 12

  monthly_payment =
    calculate_monthly_payment(monthly_interest_rate, loan_amount,
                              loan_duration_in_months)
  total_payment =
    calculate_total_payment(monthly_interest_rate, loan_amount,
                            loan_duration_in_months, monthly_payment)
  total_interest = calculate_total_interest(total_payment, loan_amount)

  prompt(format(MESSAGES["result"],
                monthly_payment: monthly_payment,
                loan_duration_in_months: loan_duration_in_months,
                total_payment: total_payment,
                total_interest: total_interest))
end

def calculate_again?
  prompt(MESSAGES['another_calc'])

  loop do
    calculate_again = gets.chomp
    return true if calculate_again.downcase == 'y'
    return false if calculate_again.downcase == 'n'
    prompt(MESSAGES['another_calc_invalid'])
  end
end

system('clear')
prompt(MESSAGES['welcome'])

loop do
  calculate_loan_parameters

  break unless calculate_again?
  system('clear')
end

prompt(MESSAGES['exit'])
