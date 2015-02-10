class AddDepositDateToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :deposit_date, :date
  end
end
