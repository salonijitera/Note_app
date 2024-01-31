class PasswordResetToken < ApplicationRecord
  belongs_to :user
  validates :token, presence: true
  validates :expires_at, presence: true
  validates :is_used, inclusion: { in: [true, false] }
end
