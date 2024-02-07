class Element < ApplicationRecord
  belongs_to :discovered_by, class_name: "User", optional: true
  has_many :recipes, foreign_key: "result_id"

  scope :default, -> { where(default: true) }
  scope :uuid, ->(uuid) { where(uuid: uuid) }
  scope :unclaimed, -> { where(discovered_by: nil) }

  def self.error
    find_by_name("error")
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
