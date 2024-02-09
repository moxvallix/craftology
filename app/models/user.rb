class User < ApplicationRecord
  VALID_UUID = /^[a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+$/i

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  
  has_many :elements, foreign_key: :discovered_by_id
  has_many :discoveries
  has_many :discovery_recipes, through: :discoveries

  validates :name, format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers and underscore" }

  attribute :claim_id

  def discovered_elements
    Element.user_discovered(self)
  end

  def claim(uuid)
    return false unless uuid.to_s.match? VALID_UUID
    Element.unclaimed.uuid(uuid).update_all(discovered_by_id: self.id)
    Recipe.unclaimed.uuid(uuid).update_all(discovered_by_id: self.id)
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

  def to_param
    name
  end

  private

  def create_discovery(element)
    Discovery.create(element: element, user: self)
  end

  def create_recipe_discovery(discovery, recipe)
    DiscoveryRecipe.create(discovery: discovery, recipe: recipe)
  end
end
