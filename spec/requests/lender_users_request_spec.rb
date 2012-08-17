require 'spec_helper'

describe 'LenderUser management' do
  let(:lender) { FactoryGirl.create(:lender, name: 'Bankers') }
  let(:current_user) { FactoryGirl.create(:lender_admin, lender: lender) }
  before { login_as(current_user, scope: :user) }

  describe 'list' do
    let!(:lender_user) { FactoryGirl.create(:lender_user, first_name: 'Barry', last_name: 'White', lender: lender) }

    let!(:cfe_admin) { FactoryGirl.create(:cfe_admin, first_name: 'David', last_name: 'Bowie') }

    it "should only show users that the current user can manage" do
      visit root_path
      click_link 'Manage Users'

      page.should have_content('Barry White')
      page.should_not have_content('David Bowie')
    end

    it 'shows warning when user does not have email address' do
      lender_user.email = nil
      lender_user.save(validate: false)

      visit root_path
      click_link 'Manage Users'

      page.should have_content('User has no email so cannot login!')
    end
  end

  describe 'create' do
    before do
      ActionMailer::Base.deliveries.clear
    end

    it do
      visit root_path
      click_link 'Manage Users'

      click_link 'New User'

      fill_in 'first_name', 'Bob'
      fill_in 'last_name', 'Flemming'
      fill_in 'email', 'bob.flemming@example.com'

      expect {
        click_button 'Create User'
      }.to change(LenderUser, :count).by(1)

      page.should have_content('Bob Flemming')
      page.should have_content('bob.flemming@example.com')

      user = LenderUser.last
      user.created_by.should == current_user
      user.modified_by.should == current_user

      # verify email is sent to user
      emails = ActionMailer::Base.deliveries
      emails.size.should == 1
      emails.first.to.should == [ user.email ]
    end
  end

  describe 'update' do
    let!(:user) { FactoryGirl.create(:lender_user, first_name: 'Bob', last_name: 'Flemming', lender: lender) }

    it do
      visit root_path
      click_link 'Manage Users'
      click_link 'Bob Flemming'

      # user has password, so no warning should be shown
      page.should_not have_content(I18n.t('manage_users.password_not_set'))

      fill_in 'first_name', 'Bill'
      fill_in 'last_name', 'Example'
      fill_in 'email', 'bill.example@example.com'
      check 'lender_user_disabled'
      check 'lender_user_locked'

      click_button 'Update User'

      page.should have_content('Bill Example')
      page.should have_content('bill.example@example.com')

      user.reload.modified_by.should == current_user
      user.should be_disabled
      user.should be_locked
    end

    it 'shows warning when user has not password' do
      user.encrypted_password = nil
      user.save(validate: false)

      visit root_path
      click_link 'Manage Users'
      click_link 'Bob Flemming'

      page.should have_content(I18n.t('manage_users.password_not_set'))
    end
  end

  describe 'unlocking the user' do
    let!(:user) { FactoryGirl.create(:lender_user, first_name: 'Bob', last_name: 'Flemming', lender: lender, locked: true) }

    it do
      visit root_path
      click_link 'Manage Users'
      click_link 'Bob Flemming'

      uncheck 'Locked'
      click_button 'Update User'

      user.reload.locked.should == false
    end
  end

  describe "sending reset password email to user without a password" do
    let!(:user) {
      user = FactoryGirl.create(
        :lender_user,
        first_name: 'Bob',
        last_name: 'Flemming',
        lender: lender,
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
      click_link 'Manage Users'
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
      click_link 'Manage Users'
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
      click_link 'Manage Users'
      click_link 'Bob Flemming'
      click_button 'Send Reset Password Email'

      page.should have_content("can't be blank")
      ActionMailer::Base.deliveries.should be_empty
    end
  end

  private
    def fill_in(attribute, value)
      page.fill_in "lender_user_#{attribute}", with: value
    end
end