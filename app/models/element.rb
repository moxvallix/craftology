class Element < ApplicationRecord
  belongs_to :discovered_by, class_name: "User", optional: true
  has_many :recipes, foreign_key: "result_id"
  has_many :discoveries

  scope :default, -> { where(default: true) }
  scope :uuid, ->(uuid) { where(discovered_uuid: uuid) }
  scope :unclaimed, -> { where(discovered_by: nil) }

  scope :user_discovered, ->(user) {
    includes(:discoveries).where(discovered_by: user).or(
      includes(:discoveries).where(discoveries: { user: user })
    )
  }

  scope :lookup, ->(search) {
    name_search = search.to_s.gsub(/[^ A-Za-z0-9]/, "")
    name_search.squeeze!(" ")
    where('LOWER(name) LIKE LOWER(?)', "%#{name_search.split(" ").join("%%")}%")
  }

  def self.error
    find_by_name("error")
  end

  def user_discovered?(user)
    return true if default?
    return false unless user.present?
    self.class.user_discovered(user).where(id: id).any?
  end

  def discoverer
    return discovered_by.name if discovered_by.present?
    "Anonymous"
  end

  def self.default_list
    out = "["
    default.map { |e| out << e.to_json.gsub(/^"|"$/, "") + ", " }
    out.delete_suffix(", ") + "]"
  end

  def to_builder
    Jbuilder.new do |json|
      json.(self, :name, :icon, :description)
    end
  end

  def recipe_strings
    recipes.map { |r| r.to_s }
  end

  def to_json
    to_builder.target!
  end
end
