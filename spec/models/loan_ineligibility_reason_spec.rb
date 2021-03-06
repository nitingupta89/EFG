require 'spec_helper'

describe LoanIneligibilityReason do

  describe "validations" do
    let(:loan_ineligibility_reason) { FactoryGirl.build(:loan_ineligibility_reason) }

    it 'has a valid Factory' do
      loan_ineligibility_reason.should be_valid
    end

    it 'strictly requires a loan_id' do
      expect {
        loan_ineligibility_reason.loan_id = nil
        loan_ineligibility_reason.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'requires a reason' do
      loan_ineligibility_reason.reason = nil
      loan_ineligibility_reason.should_not be_valid
    end
  end

end
