class User < ApplicationRecord
    validates :name, presence: true

    has_many :comments, foreign_key: 'user_id'
    has_many :posts, foreign_key: 'user_id' # Added association with posts

    # Add any additional validations here if needed
end
