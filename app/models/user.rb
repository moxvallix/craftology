class User < ApplicationRecord
  VALID_UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :discoveries
  has_many :discovery_recipes, through: :discoveries
  validates :name, format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers and underscore" }

  attribute :claim_id
  
  def claim(uuid)
    return false unless uuid.to_s.match? VALID_UUID
    Element.unclaimed.uuid(uuid).update_all(discovered_by: self)
    Recipe.unclaimed.uuid(uuid).update_all(discovered_by: self)
    true
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
