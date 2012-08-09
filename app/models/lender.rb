class Lender < ActiveRecord::Base
  has_many :admins, class_name: 'LenderAdmin'
  has_many :loans
  has_many :users, class_name: 'LenderUser'
  has_many :loan_allocations

  scope :order_by_name, order(:name)
end
