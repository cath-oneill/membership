class Member < ActiveRecord::Base
  has_many :payments
  has_many :notes

  filterrific(
    default_filter_params: { sorted_by: 'name_asc' },
    available_filters: [
      :search_query,
      :sorted_by,
      :by_zip_code,
      :last_dues_paid_gte
    ]
  )

  # default for will_paginate
  self.per_page = 10

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? :desc : :asc
    case sort_option.to_s
    when /^zip_/
      order(zip: direction)
    when /^dues_/
      order(dues_paid: direction)
    when /^name_/
      order(last_name: direction)
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

  scope :last_dues_paid_gte, lambda { |ref_date|
    where('members.dues_paid >= ?', ref_date)
  }

  scope :by_zip_code, lambda { |zips|
    where(zip: [*zips.to_s])
  }

  def self.options_for_zip_select
    pluck(:zip).uniq.map { |e| [e, e] }
  end

  def self.options_for_sorted_by
    [
      ['Last Name (a-z)', 'name_asc'],
      ['Last Name (z-a)', 'name_desc'],
      ['Dues Last Paid (oldest first)', 'dues_asc'],
      ['Dues Last Paid (newest first)', 'dues_desc'],
      ['Zip Code', 'zip_asc'],
    ]
  end  

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def set_date(date_string)
    return Date.today if date_string.nil?
    Date.parse(date_string)
  end  
end
