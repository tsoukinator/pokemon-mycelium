class Window_Base < Window
  def initialize(x, y, width, height)
    super
    self.contents = Bitmap.new(width - 32, height - 32)
  end
end

class Window_StockInfo < Window_Base
  def initialize
    # Create a window at the top-left corner
    super(0, 0, 200, 120) # x, y, width, height
    refresh
  end

  def refresh
    self.contents.clear
    self.contents.font.size = 18

    # Display player's money
    self.contents.draw_text(0, 0, 180, 24, _INTL("Money: #{format_currency($player.money)}"))

    # Display player's held stocks
    self.contents.draw_text(0, 24, 180, 24, _INTL("Stock A: #{$player.stock_a_owned}"))
    self.contents.draw_text(0, 48, 180, 24, _INTL("Stock B: #{$player.stock_b_owned}"))
    self.contents.draw_text(0, 72, 180, 24, _INTL("Stock C: #{$player.stock_c_owned}"))
  end

  def format_currency(value)
    # Format money with commas (e.g., 1,000,000)
    value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end