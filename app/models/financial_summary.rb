class FinancialSummary
  attr_reader :user, :currency, :since

  class << self
    def one_day(user:, currency:)
      new(user: user, currency: currency, since: Time.current.beginning_of_day)
    end

    def seven_days(user:, currency:)
      new(user: user, currency: currency, since: 1.week.ago)
    end

    def lifetime(user:, currency:)
      new(user: user, currency: currency, since: nil)
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
    Money.new(amount, currency.to_s.upcase)
  end

  private

  def transactions_for(category:)
    transactions = user.transactions.category(category).currency(currency)

    return transactions unless since
    return transactions.since(since)
  end
end
