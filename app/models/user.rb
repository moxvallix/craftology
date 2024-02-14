class User < ApplicationRecord
  VALID_UUID = /^[a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+$/i
  RANK_QUERY_SQLITE = 'SELECT "users"."id", row_number() OVER "win" \'rank\' FROM "users" INNER JOIN "discoveries" ON "discoveries"."user_id" = "users"."id" GROUP BY "users"."id" WINDOW "win" AS (ORDER BY COUNT("discoveries"."id") DESC)'.freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  
  has_many :elements, foreign_key: :discovered_by_id
  has_many :discoveries
  has_many :discovery_recipes, through: :discoveries
  has_many :recipes, through: :discovery_recipes
  has_many :user_badges
  has_many :badges, through: :user_badges

  scope :order_by_discovery_count, -> { joins(:discoveries).group(:id).order('COUNT(discoveries.id) DESC') }
  scope :lookup, ->(search) {
    name_search = search.to_s.gsub(/[^ A-Za-z0-9]/, "")
    name_search.squeeze!(" ")
    where('LOWER(name) LIKE LOWER(?)', "%#{name_search.split(" ").join("%%")}%")
  }

  validates :name, format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers and underscore" }, uniqueness: true

  attribute :claim_id

  def discovered_elements(filter = "")
    Element.user_discovered(self).lookup(filter.to_s).distinct
  end

  def recipes_for_element(element)
    recipes.where(result: element)
  end

  def rank
    query = User.find_by_sql(["SELECT \"rank\" FROM (#{RANK_QUERY_SQLITE}) WHERE id = ?", id])
    return -1 unless query.first
    query.first.read_attribute :rank
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
