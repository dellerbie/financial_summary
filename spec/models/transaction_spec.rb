require 'rails_helper'

describe Transaction do
  subject { build(:transaction) }

  it 'is immutable' do
    subject.save
    expect(subject.readonly?).to be true
    expect(Transaction.find(subject.id).readonly?).to be true
  end

  it 'has [deposit, refund, withdraw] as categories' do
    %i(deposit refund withdraw).each do |category|
      subject.category = category
      expect(subject.valid?).to eq(true)
    end
  end

  it 'must have greater than zero amount' do
    subject.amount = Money.from_amount(0, :usd)
    expect(subject.valid?).to eq(false)

    subject.amount = Money.from_amount(-1, :usd)
    expect(subject.valid?).to eq(false)

    subject.amount = Money.from_amount(0.01, :usd)
    expect(subject.valid?).to eq(true)
  end

  describe 'since' do
    context 'one day' do
      it 'returns all transactions for the current day' do
        t1 = Timecop.freeze(Time.current) { create(:transaction) }
        t2 = Timecop.freeze(Time.current.beginning_of_day) { create(:transaction) }
        t3 = Timecop.freeze(1.day.ago) { create(:transaction) }

        transactions = Transaction.since(Time.current.beginning_of_day).all

        expect(transactions.length).to eq(2)
        expect(transactions).to include(t1, t2)
      end
    end

    context 'one week' do
      it 'returns transactions for the past week' do
        t1 = Timecop.freeze(Time.current) { create(:transaction) }
        t2 = Timecop.freeze(1.week.ago + 5.minutes) { create(:transaction) }
        t3 = Timecop.freeze(1.week.ago - 1.day) { create(:transaction) }

        transactions = Transaction.since(1.week.ago).all

        expect(transactions.length).to eq(2)
        expect(transactions).to include(t1, t2)
      end
    end
  end
end
