class Word < ApplicationRecord
  belongs_to :user
  validates :content, presence: true
  validates :description, presence: true
end
