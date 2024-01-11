class User < ApplicationRecord
    validates :name, presence: true

    has_many :comments, foreign_key: 'user_id'

    # Add any additional validations here if needed
end
