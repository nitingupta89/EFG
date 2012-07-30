require 'spec_helper'

describe PremiumSchedule do
  describe "calculations" do
    let(:state_aid_calculation) {
      FactoryGirl.build(:state_aid_calculation,
        initial_draw_amount: Money.new(100_000_00),
        initial_draw_months: 120)
    }
    let(:premium_schedule) { PremiumSchedule.new(state_aid_calculation) }

    it "calcuates quarterly premiums" do
      [
        500_00, 487_50, 475_00, 462_50, 450_00, 437_50, 425_00, 412_50, 400_00,
        387_50, 375_00, 362_50, 350_00, 337_50, 325_00, 312_50, 300_00, 287_50,
        275_00, 262_50, 250_00, 237_50, 225_00, 212_50, 200_00, 187_50, 175_00,
        162_50, 150_00, 137_50, 125_00, 112_50, 100_00, 87_50, 75_00, 62_50,
        50_00, 37_50, 25_00, 12_50
      ].each.with_index do |premium, quarter|
        premium_schedule.premiums[quarter].should == Money.new(premium)
      end
    end

    it "calculates total premiums" do
      premium_schedule.total_premiums.should == Money.new(10_250_00)
    end
  end

  describe "#second_premium_collection_month" do
    let!(:loan) { FactoryGirl.build(:loan) }
    let!(:state_aid_calculation) { loan.state_aid_calculations.build }
    let!(:premium_schedule) { loan.premium_schedule }

    it "should return formatted date string 3 months from the initial draw date " do
      loan.initial_draw_date = Date.new(2012, 2, 24)

      premium_schedule.second_premium_collection_month.should == '05/2012'
    end

    it "should not screw up with end of month dates" do
      loan.initial_draw_date = Date.new(2011, 11, 30)

      premium_schedule.second_premium_collection_month.should == '02/2012'
    end

    it "should return nil if there is no initial draw date" do
      loan.initial_draw_date = nil

      premium_schedule.second_premium_collection_month.should be_nil
    end
  end
end
