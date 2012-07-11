class StateAidCalculationImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_CALCULATORS_DATA_TABLE.csv')
  self.klass = StateAidCalculation

  def self.field_mapping
    {
      'OID'                  => :legacy_loan_id,
      'SEQ'                  => :seq,
      'LOAN_VERSION'         => :loan_version,
      'CALC_TYPE'            => :calc_type,
      'INITIAL_DRAW_YEAR'    => :initial_draw_year,
      'PREMIUM_CHEQUE_MONTH' => :premium_cheque_month,
      'INITIAL_DRAW_AMOUNT'  => :initial_draw_amount,
      'LOAN_TERM_MONTHS'     => :initial_draw_months,
      'HOLIDAY'              => :initial_capital_repayment_holiday,
      'DRAW_AMOUNT_2'        => :second_draw_amount,
      'DRAW_MONTH_2'         => :second_draw_months,
      'DRAW_AMOUNT_3'        => :third_draw_amount,
      'DRAW_MONTH_3'         => :third_draw_months,
      'DRAW_AMOUNT_4'        => :fourth_draw_amount,
      'DRAW_MONTH_4'         => :fourth_draw_months,
      'TOTAL_COST'           => :total_cost,
      'PUBLIC_FUNDING'       => :public_funding,
      'OBJ1_AREA'            => :obj1_area,
      'REDUCE_COSTS'         => :reduce_costs,
      'IMPROVE_PROD'         => :improve_prod,
      'INCREASE_QUALITY'     => :increase_quality,
      'IMPROVE_NAT_ENV'      => :improve_nat_env,
      'PROMOTE'              => :promote,
      'AGRICULTURE'          => :agriculture,
      'GUARANTEE_RATE'       => :guarantee_rate,
      'NPV'                  => :npv,
      'PREM_RATE'            => :prem_rate,
      'EURO_CONV_RATE'       => :euro_conv_rate,
      'ELSEWHERE_PERC'       => :elsewhere_perc,
      'OBJ1_PERC'            => :obj1_perc,
      'AR_TIMESTAMP'         => :ar_timestamp,
      'AR_INSERT_TIMESTAMP'  => :ar_insert_timestamp
    }
  end

  def self.loan_id_from_legacy_id(legacy_id)
    @loan_id_from_legacy_id ||= Hash[*Loan.select('id, legacy_id').map { |loan|
      [loan.legacy_id, loan.id]
    }.flatten]

    @loan_id_from_legacy_id[legacy_id]
  end

  BOOLEANS = %w(OBJ1_AREA REDUCE_COSTS IMPROVE_PROD INCREASE_QUALITY
    IMPROVE_NAT_ENV PROMOTE AGRICULTURE)
  INTEGERS = %w(HOLIDAY TOTAL_COST PUBLIC_FUNDING)
  MONIES = %w(INITIAL_DRAW_AMOUNT)

  def attributes
    row.inject({}) { |memo, (name, value)|
      value = case name
      when *BOOLEANS
        # TODO: Cater for Yes, No and N/A values - true, false, nil.
        value.present?
      when *INTEGERS
        value.to_i
      when *MONIES
        Money.parse(value).cents
      when 'INITIAL_DRAW_YEAR'
        value.present? ? value.to_i : nil
      when 'OID'
        self.class.loan_id_from_legacy_id(value)
      else
        value
      end

      memo[self.class.field_mapping[name]] = value
      memo
    }
  end
end