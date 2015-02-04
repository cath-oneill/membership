class Member < ActiveRecord::Base
  has_many :payments
  has_many :notes

  scope :last_dues, lambda { joins(:payments).where("payments.date = (SELECT MAX(payments.date) FROM payments WHERE payments.member_id = members.id)") }


  filterrific(
    default_filter_params: { sorted_by: 'name_asc' },
    available_filters: [
      :search_query,
      :sorted_by
      # :with_country_id,
      # :with_created_at_gte
    ]
  )

  # default for will_paginate
  self.per_page = 10

  scope :last_payment, joins(:payments)

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^last_dues_paid_/
      Member.last_dues
    when /^name_/
      order("LOWER(members.last_name) #{ direction }, LOWER(members.first_name) #{ direction }")
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :search_query, lambda { |query|
    return nil  if query.blank?
    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 2
    where(
      terms.map { |term|
          "(LOWER(members.first_name) LIKE ? OR LOWER(members.last_name) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

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

  def self.options_for_sorted_by
    [
      ['Last Name (a-z)', 'name_asc'],
      ['Last Name (z-a)', 'name_desc'],
      ['Dues Last Paid', 'last_dues_paid_asc']
    ]
  end  

  private

  def set_date(date_string)
    return Date.today if date_string.nil?
    Date.parse(date_string)
  end  
end
