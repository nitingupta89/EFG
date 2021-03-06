FactoryGirl.define do
  factory :data_correction do
    loan
    created_by factory: :user
    change_type ChangeType::DataCorrection
    date_of_change { Date.current }
    modified_date { Date.current }
    data_correction_changes { {} }
  end
end
