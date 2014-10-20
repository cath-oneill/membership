class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.date :date
      t.integer :amount_cents
      t.string :type

      t.belongs_to :member

      t.timestamps
    end
  end
end
