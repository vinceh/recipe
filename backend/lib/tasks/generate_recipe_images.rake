namespace :recipes do
  desc "Generate AI images for all recipes using Gemini API"
  task generate_images: :environment do
    api_key = ENV.fetch('GEMINI_API_KEY') { raise "GEMINI_API_KEY environment variable is required" }

    service = GeminiImageService.new(api_key: api_key)
    recipes = Recipe.includes(:ingredient_groups, :recipe_ingredients, :cuisines).all

    puts "Generating images for #{recipes.count} recipes..."
    puts "=" * 60

    recipes.each_with_index do |recipe, index|
      puts "\n[#{index + 1}/#{recipes.count}] #{recipe.name}"

      # Skip if both images already generated (not the default test/seed image)
      has_card = recipe.card_image.attached? && !recipe.card_image.filename.to_s.include?("foodimg")
      has_detail = recipe.detail_image.attached? && !recipe.detail_image.filename.to_s.include?("foodimg")

      if has_card && has_detail
        puts "  Already has AI-generated images, skipping..."
        next
      end

      begin
        # Generate card image (3:4 portrait for index view)
        if has_card
          puts "  Card image: already exists"
        else
          print "  Card image (3:4)..."
          card_result = service.generate_recipe_image(recipe, aspect_ratio: "3:4")

          if card_result
            attach_image(recipe, :card_image, card_result, "card")
            puts " done"
          else
            puts " failed (no image in response)"
          end

          sleep 5
        end

        # Generate detail image (1:1 square for detail view)
        if has_detail
          puts "  Detail image: already exists"
        else
          print "  Detail image (1:1)..."
          detail_result = service.generate_recipe_image(recipe, aspect_ratio: "1:1")

          if detail_result
            attach_image(recipe, :detail_image, detail_result, "detail")
            puts " done"
          else
            puts " failed (no image in response)"
          end
        end

        # Delay between recipes
        sleep 5

      rescue => e
        if e.message.include?("429")
          puts " RATE LIMITED - waiting 60s and retrying..."
          sleep 60
          retry
        else
          puts " ERROR: #{e.message}"
          puts "  Continuing with next recipe..."
        end
      end
    end

    puts "\n" + "=" * 60
    puts "Image generation complete!"
    puts "Recipes with card images: #{Recipe.joins(:card_image_attachment).count}"
    puts "Recipes with detail images: #{Recipe.joins(:detail_image_attachment).count}"
  end

  desc "Regenerate ALL recipe images (forces replacement of existing images)"
  task regenerate_images: :environment do
    api_key = ENV.fetch('GEMINI_API_KEY') { raise "GEMINI_API_KEY environment variable is required" }

    service = GeminiImageService.new(api_key: api_key)
    recipes = Recipe.includes(:ingredient_groups, :recipe_ingredients, :cuisines).all

    puts "REGENERATING images for #{recipes.count} recipes (replacing existing)..."
    puts "=" * 60

    recipes.each_with_index do |recipe, index|
      puts "\n[#{index + 1}/#{recipes.count}] #{recipe.name}"

      begin
        # Purge existing images
        recipe.card_image.purge if recipe.card_image.attached?
        recipe.detail_image.purge if recipe.detail_image.attached?

        # Generate card image (3:4 portrait for index view)
        print "  Card image (3:4)..."
        card_result = service.generate_recipe_image(recipe, aspect_ratio: "3:4")

        if card_result
          attach_image(recipe, :card_image, card_result, "card")
          puts " done"
        else
          puts " failed (no image in response)"
        end

        sleep 5

        # Generate detail image (1:1 square for detail view)
        print "  Detail image (1:1)..."
        detail_result = service.generate_recipe_image(recipe, aspect_ratio: "1:1")

        if detail_result
          attach_image(recipe, :detail_image, detail_result, "detail")
          puts " done"
        else
          puts " failed (no image in response)"
        end

        # Delay between recipes
        sleep 5

      rescue => e
        if e.message.include?("429") || e.message.include?("503")
          puts " MODEL BUSY - waiting 30s and retrying..."
          sleep 30
          retry
        else
          puts " ERROR: #{e.message}"
          puts "  Continuing with next recipe..."
        end
      end
    end

    puts "\n" + "=" * 60
    puts "Image regeneration complete!"
    puts "Recipes with card images: #{Recipe.joins(:card_image_attachment).count}"
    puts "Recipes with detail images: #{Recipe.joins(:detail_image_attachment).count}"
  end

  desc "Generate images for a single recipe by ID"
  task :generate_image, [:recipe_id] => :environment do |t, args|
    api_key = ENV.fetch('GEMINI_API_KEY') { raise "GEMINI_API_KEY environment variable is required" }

    recipe = Recipe.includes(:ingredient_groups, :recipe_ingredients, :cuisines).find(args[:recipe_id])
    service = GeminiImageService.new(api_key: api_key)

    puts "Generating images for: #{recipe.name}"

    # Card image
    print "  Card image (3:4)..."
    card_result = service.generate_recipe_image(recipe, aspect_ratio: "3:4")
    if card_result
      attach_image(recipe, :card_image, card_result, "card")
      puts " done"
    else
      puts " failed"
    end

    sleep 2

    # Detail image
    print "  Detail image (1:1)..."
    detail_result = service.generate_recipe_image(recipe, aspect_ratio: "1:1")
    if detail_result
      attach_image(recipe, :detail_image, detail_result, "detail")
      puts " done"
    else
      puts " failed"
    end

    puts "\nComplete!"
  end

  private

  def attach_image(recipe, attachment_name, result, suffix)
    extension = result[:mime_type].split('/').last
    filename = "#{recipe.name.parameterize}-#{suffix}.#{extension}"
    decoded_data = Base64.decode64(result[:data])

    recipe.public_send(attachment_name).attach(
      io: StringIO.new(decoded_data),
      filename: filename,
      content_type: result[:mime_type]
    )
  end
end
