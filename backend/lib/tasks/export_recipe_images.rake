namespace :recipes do
  desc "Export AI-generated images from Active Storage to db/seeds/assets/recipes/"
  task export_images: :environment do
    output_dir = Rails.root.join('db/seeds/assets/recipes')
    FileUtils.mkdir_p(output_dir)

    puts "Exporting recipe images to #{output_dir}..."
    puts "=" * 60

    Recipe.find_each do |recipe|
      slug = recipe.name.parameterize

      # Export card image
      if recipe.card_image.attached?
        card_filename = "#{slug}-card.#{recipe.card_image.filename.extension}"
        card_path = output_dir.join(card_filename)
        File.open(card_path, 'wb') do |file|
          file.write(recipe.card_image.download)
        end
        puts "  ✓ #{card_filename}"
      end

      # Export detail image
      if recipe.detail_image.attached?
        detail_filename = "#{slug}-detail.#{recipe.detail_image.filename.extension}"
        detail_path = output_dir.join(detail_filename)
        File.open(detail_path, 'wb') do |file|
          file.write(recipe.detail_image.download)
        end
        puts "  ✓ #{detail_filename}"
      end
    end

    puts "=" * 60
    puts "Export complete!"
    puts "Total files: #{Dir.glob(output_dir.join('*')).count}"
  end
end
