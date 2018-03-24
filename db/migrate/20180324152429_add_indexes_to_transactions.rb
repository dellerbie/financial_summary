class AddIndexesToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_index(:transactions, [:user_id, :category, :amount_currency])
  end
end
