class UnitConverter
  CONVERSIONS = {
    # Volume
    'cup' => { 'tbsp' => 16, 'tsp' => 48, 'ml' => 240 },
    'tbsp' => { 'tsp' => 3, 'ml' => 15 },
    'tsp' => { 'ml' => 5 },

    # Weight
    'kg' => { 'g' => 1000 },
    'lb' => { 'oz' => 16, 'g' => 453.592 },
    'oz' => { 'g' => 28.3495 }
  }.freeze

  def self.convert(amount, from_unit, to_unit)
    return amount if from_unit == to_unit

    # Direct conversion
    if CONVERSIONS.dig(from_unit, to_unit)
      return amount * CONVERSIONS[from_unit][to_unit]
    end

    # Reverse conversion
    if CONVERSIONS.dig(to_unit, from_unit)
      return amount.to_f / CONVERSIONS[to_unit][from_unit]
    end

    # Multi-hop conversion via common unit
    # Try each possible intermediate unit
    from_targets = CONVERSIONS[from_unit]&.keys || []
    from_targets.each do |intermediate_unit|
      # Can we convert from intermediate to target?
      if CONVERSIONS.dig(intermediate_unit, to_unit) || CONVERSIONS.dig(to_unit, intermediate_unit)
        intermediate = convert(amount, from_unit, intermediate_unit)
        return convert(intermediate, intermediate_unit, to_unit)
      end
    end

    # No conversion found
    amount
  end

  def self.to_grams(amount, unit)
    convert(amount, unit, 'g')
  end
end
