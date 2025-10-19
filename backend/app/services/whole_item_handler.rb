class WholeItemHandler
  WHOLE_ITEMS = ['egg', 'eggs', 'onion', 'onions', 'clove', 'cloves'].freeze

  def self.scale_whole_item(item_name, amount, factor, context)
    return amount * factor unless is_whole_item?(item_name)

    scaled = amount * factor

    if context == 'baking' && scaled < 1
      # In baking, convert to grams
      { amount: (scaled * egg_weight_grams).round(1), unit: 'g', note: 'beaten egg' }
    elsif scaled < 0.3
      # Very small amounts
      { amount: 0, unit: 'whole', note: 'omit' }
    else
      # Round to nearest 0.5
      rounded = (scaled * 2).round / 2.0
      { amount: rounded, unit: 'whole' }
    end
  end

  def self.is_whole_item?(name)
    WHOLE_ITEMS.any? { |item| name.downcase.include?(item) }
  end

  private

  def self.egg_weight_grams
    50 # Average large egg
  end
end
