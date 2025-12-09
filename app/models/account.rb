class Account < ApplicationRecord
  CATEGORIES = %w[asset liability equity revenue expense].freeze

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :category, inclusion: { in: CATEGORIES }
end
