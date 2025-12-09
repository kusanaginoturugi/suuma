class ImportRule < ApplicationRecord
  MATCH_TYPES = %w[contains prefix exact].freeze
  DIRECTIONS = %w[deposit withdrawal both].freeze

  validates :keyword, presence: true
  validates :account_code, presence: true
  validates :match_type, inclusion: { in: MATCH_TYPES }
  validates :direction, inclusion: { in: DIRECTIONS }

  def self.match_for(description, direction)
    text = description.to_s.downcase
    rules = where(direction: [direction, "both"]).order(:priority, :id)
    rules.find do |rule|
      key = rule.keyword.downcase
      case rule.match_type
      when "exact"
        text == key
      when "prefix"
        text.start_with?(key)
      else
        text.include?(key)
      end
    end
  end
end
