class FinancialSummary
  attr_reader :user, :currency, :since

  class << self
    def one_day(user:, currency:)
      new(user: user, currency: currency, since: Time.current.beginning_of_day)
    end
  end

  def initialize(user:, currency:, since:)
    @user = user
    @currency = currency
    @since = since
  end

  def count(category)
    transactions_for(category: category).count
  end

  def amount(category)
    amount = transactions_for(category: category).sum(:amount_cents)
    Money.new(amount, currency_str)
  end

  private

  def currency_str
    currency.to_s.upcase
  end

  def transactions_for(category:)
    category_transactions = user.transactions.category(category)

    return category_transactions unless since
    return category_transactions.since(since)
  end
end
