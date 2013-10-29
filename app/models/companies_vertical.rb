class CompaniesVertical < ActiveRecord::Base
  # attr_accessible :company_id, :vertical_id

  belongs_to :vertical
  belongs_to :company
end
