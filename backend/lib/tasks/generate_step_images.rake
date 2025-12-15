namespace :recipes do
  desc "Generate AI step images for all recipes using Gemini API"
  task generate_step_images: :environment do
    api_key = ENV.fetch('GEMINI_API_KEY') { raise "GEMINI_API_KEY environment variable is required" }

    service = GeminiImageService.new(api_key: api_key)
    recipes = Recipe.includes(:recipe_steps, :cuisines).where.not(recipe_steps: { id: nil })

    puts "Generating step images for #{recipes.count} recipes..."
    puts "=" * 60

    recipes.each_with_index do |recipe, index|
      puts "\n[#{index + 1}/#{recipes.count}] #{recipe.name}"

      if recipe.recipe_step_images.any?
        puts "  Already has step images, skipping..."
        next
      end

      steps = recipe.recipe_steps.order(:step_number)
      if steps.count < 2
        puts "  Only #{steps.count} step(s), skipping..."
        next
      end

      crucial_steps = select_crucial_steps(steps)
      puts "  Generating images for steps: #{crucial_steps.map(&:step_number).join(', ')}"

      crucial_steps.each do |step|
        begin
          print "    Step #{step.step_number}..."
          result = service.generate_step_image(
            recipe,
            step_instruction: step.instruction_original,
            step_number: step.step_number
          )

          if result && result[:data].present?
            position = step.step_number.to_f + 0.5
            step_image = recipe.recipe_step_images.build(
              position: position,
              caption: generate_caption(step.instruction_original),
              ai_generated: true
            )
            attach_step_image(step_image, result, recipe.name, step.step_number)
            step_image.save!
            puts " done"
          else
            puts " failed (no image in response)"
          end

          sleep 5

        rescue => e
          if e.message.include?("429") || e.message.include?("503")
            puts " MODEL BUSY - waiting 30s and retrying..."
            sleep 30
            retry
          else
            puts " ERROR: #{e.message}"
          end
        end
      end

      sleep 3
    end

    puts "\n" + "=" * 60
    puts "Step image generation complete!"
    puts "Total step images created: #{RecipeStepImage.count}"
  end

  desc "Generate step images for a single recipe by ID"
  task :generate_step_images_for, [:recipe_id] => :environment do |t, args|
    api_key = ENV.fetch('GEMINI_API_KEY') { raise "GEMINI_API_KEY environment variable is required" }

    recipe = Recipe.includes(:recipe_steps, :cuisines).find(args[:recipe_id])
    service = GeminiImageService.new(api_key: api_key)

    puts "Generating step images for: #{recipe.name}"

    recipe.recipe_step_images.destroy_all

    steps = recipe.recipe_steps.order(:step_number)
    crucial_steps = select_crucial_steps(steps)

    crucial_steps.each do |step|
      print "  Step #{step.step_number}..."
      result = service.generate_step_image(
        recipe,
        step_instruction: step.instruction_original,
        step_number: step.step_number
      )

      if result && result[:data].present?
        position = step.step_number.to_f + 0.5
        step_image = recipe.recipe_step_images.build(
          position: position,
          caption: generate_caption(step.instruction_original),
          ai_generated: true
        )
        attach_step_image(step_image, result, recipe.name, step.step_number)
        step_image.save!
        puts " done"
      else
        puts " failed"
      end

      sleep 3
    end

    puts "\nComplete! Created #{recipe.recipe_step_images.count} step images."
  end

  private

  def select_crucial_steps(steps)
    return steps.to_a if steps.count <= 3

    step_count = steps.count
    target_count = [3, (step_count * 0.4).ceil].min

    crucial_keywords = [
      /mix|combine|stir|fold|whisk|blend/i,
      /cook|fry|sauté|sear|simmer|boil|bake|roast/i,
      /golden|brown|crispy|tender|done|ready/i,
      /add.*to|pour.*into|place.*in/i,
      /form|shape|roll|knead|spread/i
    ]

    scored_steps = steps.map do |step|
      score = 0
      instruction = step.instruction_original.to_s

      crucial_keywords.each do |pattern|
        score += 1 if instruction.match?(pattern)
      end

      score += 1 if instruction.length > 100
      score -= 1 if instruction.match?(/set aside|let rest|refrigerate|chill/i)

      { step: step, score: score }
    end

    sorted = scored_steps.sort_by { |s| -s[:score] }
    selected = sorted.first(target_count).map { |s| s[:step] }
    selected.sort_by(&:step_number)
  end

  def generate_caption(instruction)
    action_patterns = [
      [/until (.*?)[\.!]?$/i, ->(m) { "Until #{m[1]}" }],
      [/should (look|be|become) (.*?)[\.!]?$/i, ->(m) { "Should #{m[1]} #{m[2]}" }],
      [/^(mix|combine|stir|add|pour|cook|fry|bake)/i, ->(m) { instruction.split('.').first.strip }]
    ]

    action_patterns.each do |pattern, formatter|
      if (match = instruction.match(pattern))
        caption = formatter.call(match)
        return caption[0..79] if caption.length <= 80
      end
    end

    first_sentence = instruction.split('.').first.to_s.strip
    first_sentence.length > 60 ? first_sentence[0..57] + "..." : first_sentence
  end

  def attach_step_image(step_image, result, recipe_name, step_number)
    extension = result[:mime_type].split('/').last
    filename = "#{recipe_name.parameterize}-step-#{step_number}.#{extension}"
    decoded_data = Base64.decode64(result[:data])

    step_image.image.attach(
      io: StringIO.new(decoded_data),
      filename: filename,
      content_type: result[:mime_type]
    )
  end
end
