shared_examples_for 'AuditorUser-restricted controller' do
  let(:current_user) { FactoryGirl.create(:auditor_user) }

  before { sign_in(current_user) }

  it do
    expect {
      dispatch
    }.to raise_error(Canable::Transgression)
  end
end

shared_examples_for 'CfeAdmin-restricted controller' do
  let(:current_user) { FactoryGirl.create(:cfe_admin) }

  before { sign_in(current_user) }

  it do
    expect {
      dispatch
    }.to raise_error(Canable::Transgression)
  end
end

shared_examples_for 'CfeUser-restricted controller' do
  let(:current_user) { FactoryGirl.create(:cfe_user) }

  before { sign_in(current_user) }

  it do
    expect {
      dispatch
    }.to raise_error(Canable::Transgression)
  end
end

shared_examples_for 'LenderAdmin Lender-scoped controller' do
  let(:current_user) { FactoryGirl.create(:lender_admin) }

  before { sign_in(current_user) }

  it do
    expect {
      dispatch
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

shared_examples_for 'LenderUser Lender-scoped controller' do
  let(:current_user) { FactoryGirl.create(:lender_user) }

  before { sign_in(current_user) }

  it do
    expect {
      dispatch
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

shared_examples_for 'LenderAdmin-restricted controller' do
  let(:current_user) { FactoryGirl.create(:lender_admin) }

  before { sign_in(current_user) }

  it do
    expect {
      dispatch
    }.to raise_error(Canable::Transgression)
  end
end

shared_examples_for 'LenderUser-restricted controller' do
  let(:current_user) { FactoryGirl.create(:lender_user) }

  before { sign_in(current_user) }

  it do
    expect {
      dispatch
    }.to raise_error(Canable::Transgression)
  end
end

shared_examples_for 'PremiumCollectorUser-restricted controller' do
  let(:current_user) { FactoryGirl.create(:premium_collector_user) }

  before { sign_in(current_user) }

  it do
    expect {
      dispatch
    }.to raise_error(Canable::Transgression)
  end
end
