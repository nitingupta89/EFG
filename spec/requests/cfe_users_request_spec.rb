require 'spec_helper'

describe 'CfeUser management' do
  let(:current_user) { FactoryGirl.create(:cfe_admin) }
  before { login_as(current_user, scope: :user) }

  describe 'list' do
    before do
      FactoryGirl.create(:cfe_user, first_name: 'Barry', last_name: 'White')
      FactoryGirl.create(:lender_user, first_name: 'David', last_name: 'Bowie')
    end

    it do
      visit root_path
      click_link 'Manage CfE Users'

      page.should have_content('Barry White')
      page.should_not have_content('David Bowie')
    end
  end

  describe 'create' do
    before do
      ActionMailer::Base.deliveries.clear
    end

    it do
      visit root_path
      click_link 'Manage CfE Users'

      click_link 'New CfE User'

      fill_in 'first_name', 'Bob'
      fill_in 'last_name', 'Flemming'
      fill_in 'email', 'bob.flemming@example.com'

      expect {
        click_button 'Create CfE User'
      }.to change(CfeUser, :count).by(1)

      page.should have_content('Bob Flemming')
      page.should have_content('bob.flemming@example.com')

      user = CfeUser.last
      user.created_by.should == current_user
      user.modified_by.should == current_user

      # verify email is sent to user
      emails = ActionMailer::Base.deliveries
      emails.size.should == 1
      emails.first.to.should == [ user.email ]
    end
  end

  describe 'update' do
    let!(:user) { FactoryGirl.create(:cfe_user, first_name: 'Bob', last_name: 'Flemming') }

    it do
      visit root_path
      click_link 'Manage CfE Users'

      click_link 'Bob Flemming'

      fill_in 'first_name', 'Bill'
      fill_in 'last_name', 'Example'
      fill_in 'email', 'bill.example@example.com'
      check 'cfe_user_disabled'
      check 'cfe_user_locked'

      click_button 'Update CfE User'

      page.should have_content('Bill Example')
      page.should have_content('bill.example@example.com')

      user.reload.modified_by.should == current_user
      user.should be_disabled
      user.should be_locked
    end
  end

  describe 'unlocking the user' do
    let!(:user) { FactoryGirl.create(:cfe_user, first_name: 'Bob', last_name: 'Flemming', locked: true) }

    it do
      visit root_path
      click_link 'Manage CfE Users'
      click_link 'Bob Flemming'

      uncheck 'Locked'
      click_button 'Update CfE User'

      user.reload.locked.should == false
    end
  end

  describe "sending reset password email to user without a password" do
    let!(:user) {
      user = FactoryGirl.create(
        :cfe_user,
        first_name: 'Bob',
        last_name: 'Flemming'
      )
      user.encrypted_password = nil
      user.save(validate: false)
      user
    }

    before(:each) do
      ActionMailer::Base.deliveries.clear
    end

    it "can be sent from edit user page" do
      user.reset_password_token.should be_nil
      user.reset_password_sent_at.should be_nil

      visit root_path
      click_link 'Manage CfE Users'
      click_link 'Bob Flemming'
      click_button 'Send Reset Password Email'

      page.should have_content(I18n.t('manage_users.reset_password_sent', email: user.email))

      user.reload
      user.reset_password_token.should_not be_nil
      user.reset_password_sent_at.should_not be_nil

      # verify email is sent to user
      emails = ActionMailer::Base.deliveries
      emails.size.should == 1
      emails.first.to.should == [ user.email ]
    end

    it "can be sent from user list page" do
      visit root_path
      click_link 'Manage CfE Users'
      click_button 'Send Reset Password Email'

      page.should have_content(I18n.t('manage_users.reset_password_sent', email: user.email))
      page.should have_content(I18n.t('manage_users.password_set_time_remaining', time_left: '1 day'))
      page.should_not have_css('input', value: 'Send Reset Password Email')
    end

    # many imported users will not have an email address
    it 'fails when user does not have an email address' do
      user.email = nil
      user.save(validate: false)

      visit root_path
      click_link 'Manage CfE Users'
      click_link 'Bob Flemming'
      click_button 'Send Reset Password Email'

      page.should have_content("can't be blank")
      ActionMailer::Base.deliveries.should be_empty
    end
  end

  private
    def fill_in(attribute, value)
      page.fill_in "cfe_user_#{attribute}", with: value
    end

    def select(attribute, value)
      page.select value, from: "cfe_user_#{attribute}"
    end
end