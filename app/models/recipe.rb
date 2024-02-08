class Recipe < ApplicationRecord
  belongs_to :left_element, class_name: "Element"
  belongs_to :right_element, class_name: "Element"
  belongs_to :result, class_name: "Element", optional: true
  belongs_to :discovered_by, class_name: "User", optional: true

  enum :status, %i[active scheduled pending failed], prefix: true

  scope :craft, ->(left, right) {
    joins(:left_element, :right_element)
    .where(left_element: { name: left }, right_element: { name: right })
    .or(where(left_element: { name: right }, right_element: { name: left }))
  }
  scope :uuid, ->(uuid) { where(discovered_uuid: uuid) }
  scope :unclaimed, -> { where(discovered_by: nil) }

  def discoverer
    return discovered_by.name if discovered_by.present?
    "Anonymous"
  end

  def to_s
    return unless left_element.present? && right_element.present?
    "#{left_element.name} + #{right_element.name}"
  end
end
