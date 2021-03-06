class ExtraLendersFields < ActiveRecord::Migration
  def change
    add_column :lenders, :legacy_id, :integer
    add_column :lenders, :version, :integer
    add_column :lenders, :high_volume, :boolean
    add_column :lenders, :can_use_add_cap, :boolean
    add_column :lenders, :organisation_reference_code, :string
    add_column :lenders, :primary_contact_name, :string
    add_column :lenders, :primary_contact_phone, :string
    add_column :lenders, :primary_contact_email, :string
    add_column :lenders, :std_cap_lending_allocation, :integer
    add_column :lenders, :add_cap_lending_allocation, :integer
    add_column :lenders, :disabled, :boolean
    add_column :lenders, :created_by, :string
    add_column :lenders, :modified_by, :string
    add_column :lenders, :allow_alert_process, :boolean
    add_column :lenders, :main_point_of_contact_user, :string
    add_column :lenders, :loan_scheme, :string
    add_column :lenders, :ar_timestamp, :datetime
    add_column :lenders, :ar_insert_timestamp, :datetime

    add_index :lenders, :legacy_id, unique: true
  end
end
