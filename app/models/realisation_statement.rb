class RealisationStatement < ActiveRecord::Base
  include FormatterConcern

  PERIOD_COVERED_QUARTERS = ['March', 'June', 'September', 'December']

  belongs_to :lender
  belongs_to :created_by, class_name: 'User'
  has_many :loan_realisations
  has_many :realised_loans, through: :loan_realisations

  validates :lender_id, presence: true
  validates :created_by_id, presence: true, on: :create
  validates :reference, presence: true
  validates :period_covered_quarter, presence: true, inclusion: PERIOD_COVERED_QUARTERS
  validates :period_covered_year, presence: true, format: /\A(\d{4})\Z/
  validates :received_on, presence: true
  validate(on: :create) do |realisation_statement|
    if realisation_statement.loans_to_be_realised.none?
      errors.add(:base, 'No loans were selected.')
    end
  end

  format :received_on, with: QuickDateFormatter

  attr_accessible :lender_id, :reference, :period_covered_quarter,
                  :period_covered_year, :received_on, :loans_to_be_realised_ids

  def recovered_loans
    lender.loans.recovered.where(['recovery_on <= ?', quarter_cutoff_date])
  end

  def loans_to_be_realised
    @loans_to_be_realised || []
  end

  def loans_to_be_realised_ids=(ids)
    @loans_to_be_realised = Loan.where(id: ids)
  end

  def save_and_realise_loans
    raise LoanStateTransition::IncorrectLoanState unless loans_to_be_realised.all? {|loan| loan.state == Loan::Recovered }

    transaction do
      save!
      realise_loans!
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def quarter_cutoff_date
    month = {
      'March' => 3,
      'June' => 6,
      'September' => 9,
      'December' => 12
    }.fetch(period_covered_quarter)

    Date.new(period_covered_year.to_i, month).end_of_month
  end

  def realise_loans!
    loans_to_be_realised.update_all(state: Loan::Realised)
    loans_to_be_realised.each do |loan|
      # TODO: persist correct realised amount in LoanRealisation
      self.loan_realisations.create!(
        realised_loan: loan,
        created_by: created_by,
        realised_amount: Money.new(0)
      )
    end
  end
end
