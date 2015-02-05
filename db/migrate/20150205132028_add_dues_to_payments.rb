class AddDuesToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :dues, :boolean
  end
end
