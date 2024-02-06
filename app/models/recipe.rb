class Recipe < ApplicationRecord
  belongs_to :left_element, class_name: "Element"
  belongs_to :right_element, class_name: "Element"
  belongs_to :result, class_name: "Element", optional: true

  enum :status, %i[active scheduled pending failed], prefix: true

  scope :craft, ->(left, right) {
    joins(:left_element, :right_element)
    .where(left_element: { name: left }, right_element: { name: right })
    .or(where(left_element: { name: right }, right_element: { name: left }))
  }
end
