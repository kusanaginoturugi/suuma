class Account < ApplicationRecord
  belongs_to :parent, class_name: "Account", primary_key: :code, foreign_key: :parent_code, optional: true
  has_many :children, class_name: "Account", primary_key: :code, foreign_key: :parent_code, dependent: :nullify

  CATEGORIES = %w[asset liability equity revenue expense].freeze

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :category, inclusion: { in: CATEGORIES }
end
