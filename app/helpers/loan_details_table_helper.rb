module LoanDetailsTableHelper
  class LoanDetailsTable < ActionView::Base
    Formats = {
      ActiveSupport::TimeWithZone => ->(time) { time.strftime('%d/%m/%Y %H:%M:%S') },
      AuditorUser => :name.to_proc,
      CancelReason => :name.to_proc,
      CfeAdmin => :name.to_proc,
      CfeUser => :name.to_proc,
      Date => ->(date) { date.to_s(:screen) },
      FalseClass => 'No',
      InterestRateType => :name.to_proc,
      LegalForm => :name.to_proc,
      Lender => :name.to_proc,
      LenderAdmin => :name.to_proc,
      LenderUser => :name.to_proc,
      LendingLimit => :name.to_proc,
      LoanCategory => :name.to_proc,
      LoanSubCategory => :name.to_proc,
      LoanReason => :name.to_proc,
      Money => :format.to_proc,
      MonthDuration => :format.to_proc,
      NilClass => 'Not Set',
      PremiumCollectorUser => :name.to_proc,
      RepaymentFrequency => :name.to_proc,
      SuperUser => :name.to_proc,
      SystemUser => :username.to_proc,
      TrueClass => 'Yes'
    }

    def initialize(loan, translation_scope)
      @loan, @translation_scope = loan, translation_scope
    end

    attr_reader :loan, :translation_scope

    def row(attribute, options = {})
      content_tag(:tr) do
        header = options.fetch(:header, I18n.t("#{translation_scope}.#{attribute}"))
        value = loan.send(attribute)
        content_tag(:th, header) + content_tag(:td, format(value))
      end
    end

    private
    def format(value)
      formatted_value = Formats.fetch(value.class, value)
      if formatted_value.respond_to?(:call)
        formatted_value = formatted_value.call(value)
      end
      formatted_value
    end
  end

  def loan_details_notified_aid(value)
    case value
    when -1
      'Yes'
    when 1
      'No'
    else
      'Not Set'
    end
  end

  def loan_details_security_type_names(loan)
    security_names = loan.loan_security_types.collect(&:name).join('<br/>').html_safe
    security_names.blank? ? "Not Set" : security_names
  end

  def loan_details_table(loan, translation_scope)
    table = LoanDetailsTable.new(loan, translation_scope)
    content_tag(:table, class: 'table table-striped table-loan-details') do
      content_tag(:tbody) do
        yield table
      end
    end
  end
end
