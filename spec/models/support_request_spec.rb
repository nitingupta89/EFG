require 'spec_helper'

describe SupportRequest do

  let(:support_request) { FactoryGirl.build(:support_request) }

  describe 'validations' do
    it "has a valid factory" do
      support_request.should be_valid
    end

    it "requires a message" do
      support_request.message = nil
      support_request.should_not be_valid

      support_request.message = "help!"
      support_request.should be_valid
    end
  end

  describe "#recipients" do

    context "as a lender user" do
      let!(:lender_user) { FactoryGirl.create(:lender_user) }

      let!(:lender_admin1) { FactoryGirl.create(:lender_admin, lender: lender_user.lender) }

      let!(:lender_admin2) { FactoryGirl.create(:lender_admin, lender: lender_user.lender) }

      it "should return array of email addresses for the user's lender admins" do
        support_request.user = lender_user
        support_request.recipients.should == [ lender_admin1.email, lender_admin2.email ]
      end
    end

    %w(
      auditor_user
      lender_admin
      premium_collector_user
    ).each do |user_type|
      context "as a #{user_type.humanize}" do
        let!(:user) { FactoryGirl.create(user_type) }

        let!(:cfe_user1) { FactoryGirl.create(:cfe_user) }

        let!(:cfe_user2) { FactoryGirl.create(:cfe_user) }

        it "should return array of email addresses for all CfE users" do
          support_request.user = user
          support_request.recipients.should == [ cfe_user1.email, cfe_user2.email ]
        end
      end
    end

    %w(
      cfe_user
      cfe_admin
    ).each do |user_type|
      context "as a #{user_type.humanize}" do
        let!(:user) { FactoryGirl.create(user_type) }

        let!(:super_user1) { FactoryGirl.create(:super_user) }

        let!(:super_user2) { FactoryGirl.create(:super_user) }

        it "should return array of email addresses for all super users" do
          support_request.user = user
          support_request.recipients.should == [ super_user1.email, super_user2.email ]
        end
      end
    end

  end

end
