class Comment < ApplicationRecord
  # Validations
  validates :title, :status, presence: true
  validates :title, length: { minimum: 4 }
  validates :title, uniqueness: { message: "already taken!!" }

  # Relations
  belongs_to :user

  # Add any additional callback methods you need below
end
