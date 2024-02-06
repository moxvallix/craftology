class Element < ApplicationRecord
  belongs_to :discovered_by, class_name: "User", optional: true

  scope :default, -> { where(default: true) }
  scope :uuid, ->(uuid) { where(uuid: uuid) }
  scope :unclaimed, -> { where(discovered_by: nil) }

  def discoverer
    return discovered_by.name if discovered_by.present?
    "Anonymous"
  end

  def self.default_list
    out = "["
    all.map { |e| out << e.to_json.gsub(/^"|"$/, "") + ", " }
    out.delete_suffix(", ") + "]"
  end

  def to_builder
    Jbuilder.new do |json|
      json.(self, :name, :icon, :description)
    end
  end

  def to_json
    to_builder.target!
  end
end
