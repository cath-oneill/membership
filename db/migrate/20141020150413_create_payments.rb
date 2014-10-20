class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.date :date
      t.integer :amount_cents
      t.string :type

      t.timestamps
    end
  end
end
