class AddIndexesToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_index(:transactions, [:user_id, :category, :currency])
  end
end
