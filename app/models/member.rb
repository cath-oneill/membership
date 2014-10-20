class Member < ActiveRecord::Base
  has_many :payments

  def current_member?(date_string = nil)
    date = set_date(date_string)
    self.payments.where(date: date-365..date).present?
  end

  def paid_within_two_years?(date_string = nil)
    date = set_date(date_string)
    self.payments.where(date: date-730..date).present?
  end

  private

  def set_date(date_string)
    return Date.today if date_string.nil?
    Date.parse(date_string)
  end  
end
