# encoding: utf-8
require 'spec_helper'

describe LoanEntry do

  let(:loan_entry) { FactoryGirl.build(:loan_entry) }

  before(:each) do
    # ensure recalculate state aid validation does not fail
    Loan.any_instance.stub(:repayment_duration_changed?).and_return(false)
  end

  describe "validations" do
    it "should have a valid factory" do
      loan_entry.should be_valid
    end

    it "should be invalid if the declaration hasn't been signed" do
      loan_entry.declaration_signed = false
      loan_entry.should_not be_valid
    end

    it "should be invalid if interest rate type isn't selected" do
      loan_entry.interest_rate_type_id = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without a business name" do
      loan_entry.business_name = ''
      loan_entry.should_not be_valid
    end

    it "should be invalid without a business type" do
      loan_entry.legal_form_id = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without state_aid_is_valid" do
      loan_entry.state_aid_is_valid = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without an amount" do
      loan_entry.amount = nil
      loan_entry.should_not be_valid
    end

    context '#postcode' do
      it 'is required' do
        loan_entry.postcode = ''
        loan_entry.should_not be_valid
      end

      it 'is valid for a valid UK postcode' do
        loan_entry.postcode = 'EC1A 1BB'
        loan_entry.should be_valid
      end

      it 'is invalid without a full, valid UK postcode' do
        loan_entry.postcode = 'EC1A'
        loan_entry.should_not be_valid
      end

      it 'is invalid with only letters in the incode' do
        loan_entry.postcode = 'EC1A AAA'
        loan_entry.should_not be_valid
      end
    end

    it "should be invalid without a repayment frequency" do
      loan_entry.repayment_frequency_id = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without an interest rate" do
      loan_entry.interest_rate = ''
      loan_entry.should_not be_valid
    end

    it "should be invalid without a repayment duration" do
      loan_entry.repayment_duration = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without fees" do
      loan_entry.fees = ''
      loan_entry.should_not be_valid
    end

    it "should be invalid without state aid" do
      loan_entry.loan.state_aid = nil
      loan_entry.should_not be_valid
      loan_entry.errors[:state_aid].should == ['must be calculated']
    end

    it "should be invalid when turnover is greater than £41,000,000" do
      loan_entry.turnover = Money.new(41_000_000_01)
      loan_entry.should_not be_valid
    end

    it 'should be invalid when the trading date is blank' do
      loan_entry.trading_date = ''
      loan_entry.should_not be_valid
    end

    LegalForm.all.select { |l| l.requires_company_registration == true }.each do |legal_form|
      context "when legal_form is #{legal_form.name}" do
        it "should be invalid without company registration number" do
          loan_entry.legal_form_id = legal_form.id
          loan_entry.should_not be_valid
          loan_entry.company_registration = "B1234567890"
          loan_entry.should be_valid
        end
      end
    end

    context "when state aid exceeds SIC state aid threshold" do
      let!(:sic) { FactoryGirl.create(:sic_code, state_aid_threshold: Money.new(15_000_00)) }

      before do
        loan_entry.sic_code = sic.code
        loan_entry.state_aid = Money.new(15_000_01)
      end

      it "should be invalid" do
        loan_entry.should_not be_valid
      end
    end

    context 'when a type B loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_b) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require security types" do
        loan_entry.loan.loan_securities.clear
        loan_entry.should_not be_valid
      end

      it "should require security proportion greater than 0" do
        loan_entry.security_proportion = 0.0
        loan_entry.should_not be_valid
      end

      it "should require security proportion less than 100" do
        loan_entry.security_proportion = 100
        loan_entry.should_not be_valid
      end
    end

    context 'when a type C loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_c) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require original overdraft proportion not less than 0" do
        loan_entry.original_overdraft_proportion = -0.1
        loan_entry.should_not be_valid
      end

      it "should require original overdraft proportion less than 100" do
        loan_entry.original_overdraft_proportion = 100
        loan_entry.should_not be_valid
      end

      it "should require refinance security proportion greater than 0" do
        loan_entry.refinance_security_proportion = 0.0
        loan_entry.should_not be_valid
      end

      it "should require refinance security proportion less than or equal to 100" do
        loan_entry.refinance_security_proportion = 100.1
        loan_entry.should_not be_valid
      end
    end

    context 'when a type D loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_d) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require refinance security proportion greater than 0" do
        loan_entry.refinance_security_proportion = 0.0
        loan_entry.should_not be_valid
      end

      it "should require refinance security proportion less than or equal to 100" do
        loan_entry.refinance_security_proportion = 100.1
        loan_entry.should_not be_valid
      end

      it "should require current refinanced value" do
        loan_entry.current_refinanced_amount = nil
        loan_entry.should_not be_valid
      end

      it "should require final refinanced value" do
        loan_entry.final_refinanced_amount = nil
        loan_entry.should_not be_valid
      end
    end

    context 'when a type E loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_e) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require loan sub category" do
        loan_entry.loan_sub_category_id = nil
        loan_entry.should_not be_valid
      end

      it "should require overdraft limit" do
        loan_entry.overdraft_limit = nil
        loan_entry.should_not be_valid
      end

      it "should require overdraft maintained" do
        loan_entry.overdraft_maintained = false
        loan_entry.should_not be_valid
      end
    end

    context 'when a type G loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_g) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require overdraft limit" do
        loan_entry.overdraft_limit = nil
        loan_entry.should_not be_valid
      end

      it "should require overdraft maintained" do
        loan_entry.overdraft_maintained = false
        loan_entry.should_not be_valid
      end
    end

    context 'when a type F loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_f) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require invoice discount limit" do
        loan_entry.invoice_discount_limit = nil
        loan_entry.should_not be_valid
      end

      it "should require debtor book coverage greater than or equal to 1" do
        loan_entry.debtor_book_coverage = 0.9
        loan_entry.should_not be_valid
      end

      it "should require debtor book coverage less than 100" do
        loan_entry.debtor_book_coverage = 100
        loan_entry.should_not be_valid
      end

      it "should require debtor book topup greater than or equal to 1" do
        loan_entry.debtor_book_topup = 0.9
        loan_entry.should_not be_valid
      end

      it "should require debtor book topup less than or equal to 30" do
        loan_entry.debtor_book_topup = 30.1
        loan_entry.should_not be_valid
      end

      it "should require a total prepayment no greater than 100" do
        loan_entry.debtor_book_topup = 30
        loan_entry.debtor_book_coverage = 80
        loan_entry.should_not be_valid
      end

      it "should require a total prepayment greater than or equal to 0" do
        loan_entry.debtor_book_topup = 0
        loan_entry.debtor_book_coverage = -1
        loan_entry.should_not be_valid
      end
    end

    context 'when a type H loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_h) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require invoice discount limit" do
        loan_entry.invoice_discount_limit = nil
        loan_entry.should_not be_valid
      end

      it "should require debtor book coverage greater than or equal to 1" do
        loan_entry.debtor_book_coverage = 0.9
        loan_entry.should_not be_valid
      end

      it "should require debtor book coverage less than 100" do
        loan_entry.debtor_book_coverage = 100
        loan_entry.should_not be_valid
      end

      it "should require debtor book topup greater than or equal to 1" do
        loan_entry.debtor_book_topup = 0.9
        loan_entry.should_not be_valid
      end

      it "should require debtor book topup less than or equal to 30" do
        loan_entry.debtor_book_topup = 30.1
        loan_entry.should_not be_valid
      end
    end

    context "when repayment duration is changed" do
      before(:each) do
        # ensure recalculate state aid validation fails
        Loan.any_instance.stub(:repayment_duration_changed?).and_return(true)
      end

      it "should require a recalculation of state aid" do
        loan_entry.should_not be_valid
        loan_entry.should have(1).error_on(:state_aid)
      end
    end

    it_behaves_like 'loan presenter that validates loan repayment frequency' do
      let(:loan_presenter) { loan_entry }
    end

    it 'should require viable_proposition to be true' do
      loan_entry.viable_proposition = false

      loan_entry.should_not be_valid
      loan_entry.should have(1).error_on(:viable_proposition)
    end

    it 'should require would_you_lend to be true' do
      loan_entry.would_you_lend = false

      loan_entry.should_not be_valid
      loan_entry.should have(1).error_on(:would_you_lend)
    end

    it 'should require collateral_exhausted to be true' do
      loan_entry.collateral_exhausted = false

      loan_entry.should_not be_valid
      loan_entry.should have(1).error_on(:collateral_exhausted)
    end

    context "when sub lenders exist for the lender" do
      let!(:sub_lender) { FactoryGirl.create(:sub_lender, lender: loan_entry.lender) }

      it "must have a sub-lender" do
        loan_entry.sub_lender = nil
        expect(loan_entry).not_to be_valid
        expect(loan_entry).to have(1).error_on(:sub_lender)
      end

      it "must have an allowed sub-lender" do
        loan_entry.sub_lender = "not a valid sub lender for this lender"
        expect(loan_entry).not_to be_valid
        expect(loan_entry).to have(1).error_on(:sub_lender)
      end
    end

    context 'phase 5' do
      let(:lender) { FactoryGirl.create(:lender) }
      let(:lending_limit) { FactoryGirl.create(:lending_limit, :phase_5, lender: lender) }

      before do
        loan_entry.loan.lending_limit = lending_limit
      end

      context 'when amount is greater than £1M' do
        it "is invalid" do
          loan_entry.amount = Money.new(1_000_000_01)
          loan_entry.should_not be_valid
        end
      end
    end

    context 'phase 6' do
      let(:lender) { FactoryGirl.create(:lender) }
      let(:lending_limit) { FactoryGirl.create(:lending_limit, :phase_6, lender: lender) }

      before do
        loan_entry.loan.lending_limit = lending_limit
      end

      context 'when amount is greater than £600k and loan term is longer than 5 years' do
        it "is invalid" do
          loan_entry.amount = Money.new(600_000_01)
          loan_entry.repayment_duration = 61
          loan_entry.should_not be_valid
        end
      end

      context 'when amount is greater £1.2M' do
        it "is invalid" do
          loan_entry.amount = Money.new(1_200_000_01)
          loan_entry.should_not be_valid
        end
      end
    end
  end
end
