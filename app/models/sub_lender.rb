class SubLender < ActiveRecord::Base

  attr_accessible :name

  belongs_to :lender

  validates_presence_of :lender, strict: true
  validates_presence_of :name

end
