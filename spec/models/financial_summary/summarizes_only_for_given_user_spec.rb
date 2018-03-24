require 'rails_helper'

describe FinancialSummary do
  it 'summarizes only for the given user' do
    derrick = create(:user)
    kim = create(:user)

    [derrick, kim].each do |user|
      create(:transaction, user: user, category: :deposit)
      create(:transaction, user: user, category: :withdraw)
    end

    summary = FinancialSummary.one_day(user: derrick, currency: :usd)
    expect(summary.count(:deposit)).to eq(1)
    expect(summary.amount(:deposit)).to eq(Money.from_amount(1, :usd))
    expect(summary.count(:withdraw)).to eq(1)
    expect(summary.amount(:withdraw)).to eq(Money.from_amount(1, :usd))
  end
end
