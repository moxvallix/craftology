class Discovery < ApplicationRecord
  belongs_to :user
  belongs_to :element
  has_many :discovery_recipes
  has_many :recipes, through: :discovery_recipes

  scope :with_recipe, ->(recipe) { joins(:recipes).where(recipes: { id: recipe }) }
end
