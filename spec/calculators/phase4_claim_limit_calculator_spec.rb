require 'spec_helper'

describe 'Claim Limit Phase 4' do

  let(:lender) { FactoryGirl.create(:lender) }

  let(:claim_limit) { Phase4ClaimLimitCalculator.new(lender) }

  before do
    claim_limit.stub(:cumulative_drawn_amount).and_return(Money.new(300_000_00))
    claim_limit.stub(:settled_amount).and_return(Money.new(10_000_00))
    claim_limit.stub(:pre_claim_realisations_amount).and_return(Money.new(1_000_00))
  end

  describe "#total_amount" do
    it "returns the cumulative drawn amount x 15%" do
      claim_limit.total_amount.should == Money.new(45_000_00)
    end
  end

  describe "#amount_remaining" do
    # £45,000.00 (claim limit) + £1000 (total pre-claim realisations) - £10,000 (total settled amount)
    it "returns the claim limit amount + pre-claim limit realisations - total settled amount" do
      claim_limit.amount_remaining.should == Money.new(36_000_00)
    end
  end

  describe "#percentage_remaining" do
    it "returns the percentage of remaining claim limit" do
      claim_limit.percentage_remaining.should == 80
    end
  end

end
