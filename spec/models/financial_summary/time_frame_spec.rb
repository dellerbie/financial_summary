require 'rails_helper'

describe FinancialSummary do
  def create_user_with_transactions_on(time_in:, time_out:)
    user = create(:user)

    Timecop.freeze(time_in) do
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(2.12, :usd))
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(10, :usd))
      create(:transaction, user: user, category: :withdraw, amount: Money.from_amount(0.12, :usd))
      create(:transaction, user: user, category: :refund, amount: Money.from_amount(5, :usd))
    end

    Timecop.freeze(time_out) do
      create(:transaction, user: user, category: :deposit)
      create(:transaction, user: user, category: :refund)
      create(:transaction, user: user, category: :withdraw)
    end

    user
  end

  it 'summarizes over one day' do
    user = create_user_with_transactions_on(time_in: Time.current, time_out: 2.days.ago)

    summary = FinancialSummary.one_day(user: user, currency: :usd)

    expect(summary.count(:deposit)).to eq(2)
    expect(summary.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))
    expect(summary.count(:withdraw)).to eq(1)
    expect(summary.amount(:withdraw)).to eq(Money.from_amount(0.12, :usd))
    expect(summary.count(:refund)).to eq(1)
    expect(summary.amount(:refund)).to eq(Money.from_amount(5, :usd))
  end

  it 'summarizes over seven days' do
    user = create_user_with_transactions_on(time_in: 5.days.ago, time_out: 8.days.ago)

    summary = FinancialSummary.seven_days(user: user, currency: :usd)

    expect(summary.count(:deposit)).to eq(2)
    expect(summary.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))
    expect(summary.count(:withdraw)).to eq(1)
    expect(summary.amount(:withdraw)).to eq(Money.from_amount(0.12, :usd))
    expect(summary.count(:refund)).to eq(1)
    expect(summary.amount(:refund)).to eq(Money.from_amount(5, :usd))
  end

  it 'summarizes over lifetime' do
    user = create_user_with_transactions_on(time_in: 8.days.ago, time_out: 30.days.ago)

    summary = FinancialSummary.lifetime(user: user, currency: :usd)

    expect(summary.count(:deposit)).to eq(3)
    expect(summary.amount(:deposit)).to eq(Money.from_amount(13.12, :usd))
    expect(summary.count(:withdraw)).to eq(2)
    expect(summary.amount(:withdraw)).to eq(Money.from_amount(1.12, :usd))
    expect(summary.count(:refund)).to eq(2)
    expect(summary.amount(:refund)).to eq(Money.from_amount(6, :usd))
  end
end
