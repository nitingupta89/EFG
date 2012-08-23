require 'spec_helper'
require 'importers'

describe LoanStateChangeImporter do

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/SFLG_LOAN_AUDIT_DATA_TABLE.csv') }

  let!(:user1) { FactoryGirl.create(:user, username: 'cric2666s') }

  let!(:user2) { FactoryGirl.create(:user, username: 'jake1234p') }

  describe ".import" do
    before do
      LoanStateChangeImporter.instance_variable_set(:@user_id_from_username, nil)
    end

    def dispatch
      LoanStateChangeImporter.csv_path = csv_fixture_path
      LoanStateChangeImporter.import
    end

    it "should create new records" do
      expect {
        dispatch
      }.to change(LoanStateChange, :count).by(2)
    end

    it "should import data correctly" do
      dispatch

      loan_state_change1 = LoanStateChange.first
      loan_state_change1.legacy_id = 144765
      loan_state_change1.version.should == 0
      loan_state_change1.state.should == Loan::Eligible
      loan_state_change1.modified_on.should == Date.parse("24-MAY-07")
      loan_state_change1.modified_by.should == User.find_by_username!('cric2666s')
      loan_state_change1.event_id.should == 1

      loan_state_change2 = LoanStateChange.last
      loan_state_change2.legacy_id = 144765
      loan_state_change2.version.should == 2
      loan_state_change2.state.should == Loan::Incomplete
      loan_state_change2.modified_on.should == Date.parse("26-MAY-07")
      loan_state_change2.modified_by.should == User.find_by_username!('jake1234p')
      loan_state_change2.event_id.should == 2
    end
  end

end
