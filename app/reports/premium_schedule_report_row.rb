class PremiumScheduleReportRow
  HEADERS = ['Draw Down Date', 'Lender organisation', 'Loan reference',
    'Schedule Type', 'Initial Premium Cheque', '1st Collection Date',
    'No of Payments'] + (1..40).map { |i| "Premium#{i}" }

  attr_accessor :loan, :state_aid_calculation

  def self.from_loans(loans)
    state_aid_calculation_ids = loans.map(&:state_aid_calculation_id)
    state_aid_calculations = StateAidCalculation.find(state_aid_calculation_ids)
    state_aid_calculation_lookup = state_aid_calculations.index_by(&:loan_id)

    loans.map do |loan|
      new(loan).tap do |row|
        row.state_aid_calculation = state_aid_calculation_lookup[loan.id]
      end
    end
  end

  def initialize(loan)
    @loan = loan
  end

  def premium_schedule
    @premium_schedule ||= PremiumSchedule.new(state_aid_calculation, loan)
  end

  def to_csv
    [
      loan.draw_down_date.strftime('%d-%m-%Y'),
      loan.lender_organisation,
      loan.reference,
      state_aid_calculation.calc_type,
      premium_schedule.initial_premium_cheque.to_f,
      first_collection_month,
      premium_schedule.number_of_subsequent_payments,
    ] + premiums
  end

  private

  def premiums
    array = premium_schedule.subsequent_premiums.map(&:to_f)
    array.unshift(0.0) unless premium_schedule.reschedule?
    array
  end

  def first_collection_month
    if state_aid_calculation.premium_cheque_month.present?
      state_aid_calculation.premium_cheque_month
    else
      loan.draw_down_date.advance(months: 3).strftime('%m/%Y')
    end
  end

end
