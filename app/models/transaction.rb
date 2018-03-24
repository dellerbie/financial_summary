class Transaction < ApplicationRecord
  monetize :amount_cents

  validate :must_be_greater_than_zero
  validates :category, inclusion: %w[deposit refund withdraw]

  belongs_to :user

  after_save :make_immutable
  after_find :make_immutable

  scope :since, ->(time) { where('created_at >= ?', time) }
  scope :category, ->(category) { where(category: category) }
  scope :currency, ->(currency) { where(amount_currency: currency.to_s.upcase) }

  private

  def must_be_greater_than_zero
    errors.add(:amount, 'Must be greater than 0') if amount <= Money.from_amount(0, amount_currency)
  end

  def make_immutable
    self.readonly!
  end
end
