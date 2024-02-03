RECIPES = [
  ["dirt", ["earth", "earth"]],
  ["atmosphere", ["earth", "air"]],
  ["plant", ["earth", "water"]],
  ["wind", ["air", "air"]],
  ["cloud", ["air", "water"]],
  ["lava", ["fire", "earth"]],
  ["smoke", ["fire", "air"]],
  ["heat", ["fire", "fire"]],
  ["steam", ["water", "fire"]],
  ["ocean", ["water", "water"]],
]

RECIPES.each do |result, ingredients|
  element = Element.find_by_name result
  next unless element.present?
  recipe = Recipe.craft(*ingredients).where(result: element).first
  next if recipe.present?
  left = Element.find_by_name ingredients[0]
  right = Element.find_by_name ingredients[1]
  Recipe.create(result: element, left_element: left, right_element: right)
end