class Payment < ActiveRecord::Base
  belongs_to :member
  monetize :amount_cents
end
