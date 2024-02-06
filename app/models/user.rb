class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :discoveries
  has_many :discovery_recipes, through: :discoveries
  validates :name, format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers and underscore" }
  
  def claim(uuid)
    Element.unclaimed.uuid(uuid).update_all(discovered_by: self)
    Recipe.unclaimed.uuid(uuid).update_all(discovered_by: self)
  end

  def discover(recipe)
    return true if discoveries.with_recipe(recipe).any?
    element = recipe.result
    return false unless element.is_a? Element
    discovery = discoveries.where(element: element).first
    ActiveRecord::Base.transaction do
      discovery ||= create_discovery(element)
      create_recipe_discovery(discovery, recipe)
    end
    true
  end

  private

  def create_discovery(element)
    Discovery.create(element: element, user: self)
  end

  def create_recipe_discovery(discovery, recipe)
    DiscoveryRecipe.create(discovery: discovery, recipe: recipe)
  end
end
