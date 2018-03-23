require 'rails_helper'

describe FinancialSummary do
  def create_transactions_from(user:, timeframe:)
    Timecop.freeze(timeframe.end) do
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(2.12, :usd))
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(10, :usd))
      create(:transaction, user: user, category: :withdraw, amount: Money.from_amount(0.12, :usd))
      create(:transaction, user: user, category: :refund, amount: Money.from_amount(5, :usd))
    end

    Timecop.freeze(timeframe.begin) do
      create(:transaction, user: user, category: :deposit)
      create(:transaction, user: user, category: :refund)
      create(:transaction, user: user, category: :withdraw)
    end
  end

  it 'summarizes over one day' do
    user = create(:user)
    create_transactions_from(user: user, timeframe: 2.days.ago..Time.current)

    subject = FinancialSummary.one_day(user: user, currency: :usd)

    expect(subject.count(:deposit)).to eq(2)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))
    expect(subject.count(:withdraw)).to eq(1)
    expect(subject.amount(:withdraw)).to eq(Money.from_amount(0.12, :usd))
    expect(subject.count(:refund)).to eq(1)
    expect(subject.amount(:refund)).to eq(Money.from_amount(5, :usd))
  end

  it 'summarizes over seven days' do
    user = create(:user)
    create_transactions_from(user: user, timeframe: 8.days.ago..5.days.ago)

    subject = FinancialSummary.seven_days(user: user, currency: :usd)

    expect(subject.count(:deposit)).to eq(2)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))
    expect(subject.count(:withdraw)).to eq(1)
    expect(subject.amount(:withdraw)).to eq(Money.from_amount(0.12, :usd))
    expect(subject.count(:refund)).to eq(1)
    expect(subject.amount(:refund)).to eq(Money.from_amount(5, :usd))
  end

  it 'summarizes over lifetime' do
    user = create(:user)
    create_transactions_from(user: user, timeframe: 30.days.ago..8.days.ago)

    subject = FinancialSummary.lifetime(user: user, currency: :usd)

    expect(subject.count(:deposit)).to eq(3)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(13.12, :usd))
    expect(subject.count(:withdraw)).to eq(2)
    expect(subject.amount(:withdraw)).to eq(Money.from_amount(1.12, :usd))
    expect(subject.count(:refund)).to eq(2)
    expect(subject.amount(:refund)).to eq(Money.from_amount(6, :usd))
  end
end
