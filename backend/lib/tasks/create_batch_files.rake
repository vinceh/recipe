namespace :ingredients do
  desc "Create batch files for ingredient processing"
  task create_batches: :environment do
    require "json"

    batch_size = 30
    total = Ingredient.count
    batches = (total.to_f / batch_size).ceil

    puts "Total ingredients: #{total}"
    puts "Batches to create: #{batches}"

    Ingredient.select(:id, :canonical_name, :category).order(:id).each_slice(batch_size).with_index(1) do |batch, idx|
      data = batch.map { |i| { id: i.id, name: i.canonical_name, category: i.category } }
      File.write(Rails.root.join("tmp", "batch_#{idx}.json"), JSON.pretty_generate(data))
      print "." if idx % 10 == 0
    end
    puts "\nDone creating #{batches} batch files"
  end
end
