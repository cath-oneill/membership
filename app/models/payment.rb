class Payment < ActiveRecord::Base
  belongs_to :member

  after_save :update_member_dues_paid
  
  monetize :amount_cents

  filterrific(
    default_filter_params: { sorted_by: 'date_desc' },
    available_filters: [
      :search_query,
      :sorted_by,
      :selection,
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
    when /^deposit_date_/
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

  scope :selection, lambda { |keyword|
    field = keyword.split("_").first
    value = keyword.split("_")[1]
    case field
    when "dues"
      where(dues: value)
    when "date"
      where(date: nil)
    when "depositdate"
      where(deposit_date: nil)      
    when "kind"
      where(kind: value)
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }


  scope :date_gte, lambda { |ref_date|
    where('payments.date >= ?', ref_date)
  }

  scope :date_lte, lambda { |ref_date|
    where('payments.date <= ?', ref_date)
  }

  scope :deposit_date_gte, lambda { |ref_date|
    where('payments.deposit_date >= ?', ref_date)
  }

  scope :deposit_date_lte, lambda { |ref_date|
    where('payments.deposit_date <= ?', ref_date)
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

  def self.import_new(file)
    not_created = []
    headers = CSV.read(file.path)[0]

    unless headers.include?("amount") && headers.include?("date") && headers.include?("member_first_name") && headers.include?("member_last_name")
      raise "Import Cancelled: Incorrect Required Headers"
    end

    CSV.foreach(file.path, headers: true) do |row|
      payment_hash = row.to_hash 

      if payment_hash["amount"].nil? || payment_hash["date"].nil? || payment_hash["member_first_name"].nil? || payment_hash["member_last_name"].nil?
        not_created << "row missing required data"
        next
      end

      member = Member.where(first_name: payment_hash["member_first_name"], last_name: payment_hash["member_last_name"])
      if member.length != 1
        not_created << "cannot find member - #{payment_hash["member_first_name"]} #{payment_hash["member_last_name"]}"
        next
      end

      new_date = Date.parse(payment_hash["date"])
      payment_hash["date"] = new_date      
      
      payment = member.first.payments.where("date >?", (payment_hash["date"] - 2.months)).where("date < ?", (payment_hash["date"] + 2.months)).where(amount_cents: (payment_hash["amount"].to_f * 100))
      if payment.empty?
        payment_hash = payment_hash.slice("amount", "date", "note", "dues")
        payment_hash["member_id"] = member.first.id
        Payment.create!(payment_hash)
      else
        not_created << "conflicts with another payment - #{payment_hash["member_first_name"]} #{payment_hash["member_last_name"]}"
      end
    end # end CSV.foreach
    return not_created
  end # end self.import(file)

  def self.options_for_sorted_by
    [
      ['Amount (smallest first)', 'amount_asc'],
      ['Amount (largest first)', 'amount_desc'],
      ['Date (oldest first)', 'date_asc'],
      ['Date (newest first)', 'date_desc'],
      ['Deposit Date (newest first)', 'deposit_date_asc'],
      ['Deposit Date (oldest first)', 'deposit_date_desc'],
    ]
  end  

  def self.options_for_selection
    array = [
      ['Dues Payments', 'dues_true'],
      ['Non-Dues Payments', 'dues_false'],
      ['Missing Date', 'date_nil'],
      ['Missing Deposit Date', 'depositdate_nil'],
      ['Missing Kind', 'kind_']
    ]
    Setting.where(lookup: "payment_kinds").first.value.scan(/\w+/).each do |k|
      array << ["#{k.capitalize} Payment", "kind_#{k}"]
    end
    return array
  end

  def update_member_dues_paid
    if member.dues_paid.nil? || date > member.dues_paid 
      Member.update(member_id, {dues_paid: date})
    end
  end
end
