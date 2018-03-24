require 'rails_helper'

describe FinancialSummary do
  it 'summarizes only for the given currency' do
    derrick = create(:user)

    create(:transaction, user: derrick, category: :deposit, amount: Money.from_amount(1, :usd))
    create(:transaction, user: derrick, category: :deposit, amount: Money.from_amount(1, :eur))

    summary = FinancialSummary.one_day(user: derrick, currency: :eur)
    expect(summary.count(:deposit)).to eq(1)
    expect(summary.amount(:deposit)).to eq(Money.from_amount(1, :eur))
  end
end
