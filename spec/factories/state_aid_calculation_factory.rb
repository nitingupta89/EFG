FactoryGirl.define do
  factory :state_aid_calculation do
    loan
    initial_draw_year 2012
    initial_draw_amount { |o| o.loan.amount }
    initial_draw_months 12
  end
end