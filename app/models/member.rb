class Member < ActiveRecord::Base
  has_many :payments
  has_many :notes

  filterrific(
    default_settings: { sorted_by: 'name_desc' },
    filter_names: [
      :search_query,
      :sorted_by
      # :with_country_id,
      # :with_created_at_gte
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^membership_ends_/
      order("members.expiration_date #{ direction }")
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
    num_or_conditions = 3
    where(
      terms.map {
        or_clauses = [
          "LOWER(members.first_name) LIKE ?",
          "LOWER(members.last_name) LIKE ?",
          "LOWER(members.email) LIKE ?"
        ].join(' OR ')
        "(#{ or_clauses })"
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

  private

  def set_date(date_string)
    return Date.today if date_string.nil?
    Date.parse(date_string)
  end  
end
