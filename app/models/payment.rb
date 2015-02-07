class Payment < ActiveRecord::Base
  belongs_to :member

  after_save :update_member_dues_paid
  
  monetize :amount_cents

  filterrific(
    default_filter_params: { sorted_by: 'date_desc' },
    available_filters: [
      :search_query,
      :sorted_by,
      :by_dues,
      :date_gte,
      :date_lte,
      :amount_gte,
      :amount_lte
    ]
  )  

  # default for will_paginate
  self.per_page = 10

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? :desc : :asc
    case sort_option.to_s
    when /^amount_/
      order(amount_cents: direction)
    when /^date_/
      order(date: direction)
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
    joins(:member).where(
      terms.map { |term|
        "members.last_name ILIKE ? OR members.first_name ILIKE ? OR payments.note ILIKE ?"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :by_dues, lambda { |boolean|
    where(dues: boolean)
  }

  scope :date_gte, lambda { |ref_date|
    where('payments.date >= ?', ref_date)
  }

  scope :date_lte, lambda { |ref_date|
    where('payments.date <= ?', ref_date)
  }

  scope :amount_gte, lambda { |ref_amount|
    where('payments.amount_cents >= ?', ref_amount*100)
  }

  scope :amount_lte, lambda { |ref_amount|
    where('payments.amount_cents <= ?', ref_amount*100)
  }

  def self.to_csv
    CSV.generate do |csv|
      columns = ["id", "date", "amount",  "member_id", "member_name", "note", "dues"]
      csv << columns
      all.each do |payment|
        information = payment.attributes.values_at("id", "date", "member_id", "note", "dues")
        information.insert(2, payment.amount_cents/100)
        information.insert(4, payment.member.full_name)
        csv << information
      end
    end
  end

  def self.options_for_sorted_by
    [
      ['Amount (smallest first)', 'amount_asc'],
      ['Amount (largest first)', 'amount_desc'],
      ['Date (oldest first)', 'date_asc'],
      ['Date (newest first)', 'date_desc'],
    ]
  end  

  def self.options_for_dues_select
    [
      ['Dues Payments', true],
      ['Non-Dues Payments', false]
    ]
  end

  def update_member_dues_paid
    if member.dues_paid.nil? || date > member.dues_paid 
      Member.update(member_id, {dues_paid: date})
    end
  end
end
