def stock_menu()
  # Get Stock Prices
  stock_price_a = get_day_data(626, 30, starting_value = 50, volt = 5, mult = 2)
  stock_price_b = get_day_data(555, 30, starting_value = 20, volt = 1, mult = 2)
  stock_price_c = get_day_data(123, 30, starting_value = 500, volt = 15, mult = 2)
  
  #stocks = ["Stock A","Stock B","Stock C"]
  
  # Extract the 'value' from each stock's data
  stock_values = [
    stock_price_a[:value].round(0),  # Assuming the value is stored with the key :value
    stock_price_b[:value].round(0),
    stock_price_c[:value].round(0)
  ]
  
  # Format the stock values into a string for display
  stocks_with_values = [
    "Stock A - $#{stock_values[0]}",
    "Stock B - $#{stock_values[1]}",
    "Stock C - $#{stock_values[2]}"
  ]
  
  # Display the stock values to the user
  pbMessage(_INTL("Welcome to the stock market"))
  op = pbMessage(_INTL("What would you like to do?"), ["Buy","Sell","View Holdings"], -1)
  if op == -1
    #next
  elsif op == 0
    ###### BUY MENU ########
    choice = pbMessage(_INTL("What would you like to buy?"), stocks_with_values, -1) # -1 allows Cancel option
    #pbMessage(_INTL("Choice: #{choice}"))
    if choice == -1
      #
    elsif choice == 0
      return buy_stock(stock_id="A")
    elsif choice == 1
      return buy_stock(stock_id="B")
    elsif choice == 2
      return buy_stock(stock_id="C")
    end
  elsif op == 1
    ### SELL MENU ###########
    choice = pbMessage(_INTL("What would you like to sell"), stocks_with_values, -1) # -1 allows Cancel option
    #pbMessage(_INTL("Choice: #{choice}"))
    if choice == -1
      #
    elsif choice == 0
      return sell_stock(stock_id="A")
    elsif choice == 1
      return sell_stock(stock_id="B")
    elsif choice == 2
      return sell_stock(stock_id="C")
    end
  elsif op == 2
    ###### VIEW HOLDINGS #####
    show_player_stocks()
  end
  #return pbMessage(_INTL("Stock Owned: #{$player.stock_a_owned}"))
end
  
  # Present the choice between the two sets
#  set_names = sets.map { |set| _INTL(set[0]) }
  # Add an "Exit" option at the end
#  set_names.push(_INTL("Exit"))


# Function to generate deterministic random number based on seed and day
def seeded_random(seed, day)
  srand(seed + day) # Set the random seed
  rand # Generate a random number between 0 and 1
end

# Function to get data for a specific day with multiplier and volatility
def get_day_data(seed, day_no, starting_value = 50, volt = 5, mult = 2)
  raise ArgumentError, 'DayNo must be >= 1' if day_no < 1

  # Calculate the deterministic random number for the given day
  random_value = seeded_random(seed, day_no)

  # Calculate percentage change (scaled between -volt to +volt)
  pct_change = ((random_value * 2 - 1) * volt * mult / 100.0)

  # Calculate the value iteratively for the given day
  current_value = starting_value
  (2..day_no).each do |day|
    random_value_day = seeded_random(seed, day)
    pct_change_day = ((random_value_day * 2 - 1) * volt * mult / 100.0)
    current_value *= (1 + pct_change_day)
  end

  # Return a hash with the data for the specified day
  stock = {
    day: day_no,
    random_value: random_value.round(2),
    pct_change: pct_change.round(2),
    value: current_value.round(2),
    multiplier: mult,
    volatility: volt
  }  
  
  return stock
  #return pbMessage(_INTL("Stock for Day #{stock[:day]}: Value = #{stock[:value]}, Pct Change = #{stock[:pct_change]}"))
end


# Example usage
#seed = 123
#day_no = 10
#starting_value = 50
#volt = 5
#mult = 2

#result = get_day_data(seed, day_no, starting_value, volt, mult)
#puts result

def show_player_stocks()
  # Get current prices
  stock_price_a = get_day_data(626, 30, starting_value = 50, volt = 5, mult = 2)
  stock_price_b = get_day_data(555, 30, starting_value = 20, volt = 1, mult = 2)
  stock_price_c = get_day_data(123, 30, starting_value = 500, volt = 15, mult = 2)
  
  stock_value_a = (stock_price_a[:value] * $player.stock_a_owned).round(0)
  stock_value_b = (stock_price_b[:value] * $player.stock_b_owned).round(0)
  stock_value_c = (stock_price_c[:value] * $player.stock_c_owned).round(0)
  
  # Player stocks
    player_stocks = [
    "Stock A - #{$player.stock_a_owned}, ($#{stock_value_a})",
    "Stock B - #{$player.stock_b_owned}, ($#{stock_value_b})",
    "Stock C - #{$player.stock_c_owned}, ($#{stock_value_c})"
  ]
  
  pbMessage(_INTL("Player stocks"), player_stocks, -1) 
end

## Buy stock function
def buy_stock(stock_id="A", count=5)
  # Ask player quantity of stock to purchase
  batches = [5, 50, 200]  # Use integer values instead of strings
  qty_index = pbMessage(_INTL("How many stocks?"), batches.map { |b| "#{b}" }, -1)  # -1 allows Cancel option
  
  if qty_index == -1
    # Do nothing, cancel
    return
  end
  
  # Get the selected quantity based on the index
  qty = batches[qty_index]  # Get the actual value based on the index
  
  if stock_id == "A"
    stock = get_day_data(626, 30, starting_value = 50, volt = 5, mult = 2)
  elsif stock_id == "B"
    stock = get_day_data(555, 30, starting_value = 20, volt = 1, mult = 2)
  elsif stock_id == "C"
    stock = get_day_data(123, 30, starting_value = 500, volt = 15, mult = 2)
  else
    #
  end
    
  # Check if player can afford the stock
    stock_value = (qty * stock[:value]).round(0)
    if stock_value > $player.money
      pbMessage(_INTL("You can't afford that! You only have #{$player.money}"))
      
    elsif
      # Deduct balance from player
      $player.money -= stock_value
      # Complete the purchase
      if stock_id == "A"
        $player.stock_a_owned += qty
        $stats.stock_a_purchased_cnt += $stats.stock_a_purchased_cnt + qty
      elsif stock_id == "B"
        $player.stock_b_owned += qty
        $stats.stock_b_purchased_cnt += $stats.stock_b_purchased_cnt + qty
      elsif stock_id == "C"
        $player.stock_c_owned += qty
        $stats.stock_c_purchased_cnt += $stats.stock_c_purchased_cnt + qty        
      end
      pbMessage(_INTL("Purchased #{qty} #{stock_id} stocks for: #{stock_value}"))
    end
    #pbMessage(_INTL("Stock Owned: #{$player.stock_a_owned}"))
end

## Sell stock function
def sell_stock(stock_id="A", count=5)
  # Ask player quantity of stock to purchase
  batches = [5, 50, 200]  # Use integer values instead of strings
  qty_index = pbMessage(_INTL("How many stocks?"), batches.map { |b| "#{b}" }, -1)  # -1 allows Cancel option
  
  if qty_index == -1
    # Do nothing, cancel
    return
  end
  
  # Get the selected quantity based on the index
  qty = batches[qty_index]  # Get the actual value based on the index
  
  if stock_id == "A"
    stock = get_day_data(626, 30, starting_value = 50, volt = 5, mult = 2)
    player_stock_owned = $player.stock_a_owned
  elsif stock_id == "B"
    stock = get_day_data(555, 30, starting_value = 20, volt = 1, mult = 2)
    player_stock_owned = $player.stock_b_owned
  elsif stock_id == "C"
    stock = get_day_data(123, 30, starting_value = 500, volt = 15, mult = 2)
    player_stock_owned = $player.stock_c_owned
  else
    return
  end
    
  # Check if player has enough stocks to sell
  player_stock_cnt = stock[:value]
  
  if player_stock_owned < qty
    pbMessage(_INTL("You don't have that many stocks! You only have #{player_stock_owned}"))
    return
  end
  
  stock_value = (qty * stock[:value]).round(0)
  
  # Add balance to player
  $player.money += stock_value
  # Complete the sale
  if stock_id == "A"
    $player.stock_a_owned -= qty
    $stats.stock_a_sold_cnt += qty
  elsif stock_id == "B"
    $player.stock_b_owned -= qty
    $stats.stock_b_sold_cnt += qty
  elsif stock_id == "C"
    $player.stock_c_owned -= qty
    $stats.stock_c_sold_cnt += qty        
  end
  
  pbMessage(_INTL("Sold #{qty} #{stock_id} stocks for: #{stock_value}"))
end

  
# Only use to set for first time/reset
def reset_player_stocks()
  $player.stock_a_owned = 0
  $player.stock_b_owned = 0
  $player.stock_c_owned = 0
  $stats.stock_a_purchased_cnt        = 0
  $stats.stock_b_purchased_cnt        = 0
  $stats.stock_c_purchased_cnt        = 0
  $stats.stock_a_purchased_val        = 0
  $stats.stock_b_purchased_val        = 0
  $stats.stock_c_purchased_val        = 0
  $stats.stock_a_sold_cnt             = 0
  $stats.stock_b_sold_cnt             = 0
  $stats.stock_c_sold_cnt             = 0
  $stats.stock_a_sold_val             = 0
  $stats.stock_b_sold_val             = 0
  $stats.stock_c_sold_val             = 0
end
