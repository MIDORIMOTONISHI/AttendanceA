class Base < ApplicationRecord
  validates :base_number, presence: true
  validates :base_name, presence: true
end
