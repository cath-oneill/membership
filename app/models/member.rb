class Member < ActiveRecord::Base
  has_many :payments
  has_many :notes

  def current_member?(date_string = nil)
    date = set_date(date_string)
    self.payments.where(date: date-365..date).present?
  end

  def paid_within_three_years?(date_string = nil)
    date = set_date(date_string)
    self.payments.where(date: date-1096..date).present?
  end

  def expiration_date
    self.payments.order(:date).last.date + 365
  end

  private

  def set_date(date_string)
    return Date.today if date_string.nil?
    Date.parse(date_string)
  end  
end
