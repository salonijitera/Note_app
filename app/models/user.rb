
class User < ApplicationRecord
  # Existing relations and validations
  has_many :password_reset_tokens, dependent: :destroy
end
