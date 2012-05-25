class LoanOffer
  include LoanStateTransition

  attribute :facility_letter_date
  attribute :facility_letter_sent

  def facility_letter_date=(value)
    loan.facility_letter_date = QuickDateFormatter.parse(value)
  end

  def lending_limit_details
    loan.lender_cap.name
  end
end
