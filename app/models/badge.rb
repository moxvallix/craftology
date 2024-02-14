class Badge < ApplicationRecord
  validates :name, :icon, presence: true
end
