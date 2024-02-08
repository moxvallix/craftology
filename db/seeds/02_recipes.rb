RECIPES = "db/seeds/fixtures/recipes.json".freeze

JSON.parse(File.read(RECIPES)).each do |left_name, right_name, result|
  puts result
  element = Element.find_by_name! result
  recipe = Recipe.craft(left_name, right_name).where(result: element).first
  next if recipe.present?
  left = Element.find_by_name! left_name
  right = Element.find_by_name! right_name
  Recipe.create!(result: element, left_element: left, right_element: right)
rescue => e
  raise "Error processing recipe: #{left_name} + #{right_name} = #{result}"
end