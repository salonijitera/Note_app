class Page < ApplicationRecord
    validates :name, :content, presence: true
    validates :name, :content, length: { minimum: 4 }
    validates :name, uniqueness: { message: "already taken!!" }
end
