class Element < ApplicationRecord
  scope :default, -> { where(default: true) }

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

  def to_json
    to_builder.target!
  end
end
