class Comment < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :post

  # Validations
  validates :title, presence: true, length: { minimum: 4 }, uniqueness: { message: "already taken!!" }
  validates :status, presence: true

  # Add any additional methods or callback methods you need below
end
