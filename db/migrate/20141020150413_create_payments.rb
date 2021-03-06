class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.date :date
      t.integer :amount_cents
      t.money :amount
      t.string :kind

      t.belongs_to :member

      t.timestamps
    end
  end
end
