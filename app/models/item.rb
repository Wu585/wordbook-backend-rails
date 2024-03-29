class Item < ApplicationRecord
  enum kind: { expenses: 1, income: 2 }
  validates :amount, presence: true
  validates :amount, numericality: { other_than: 0 }
  validates :kind, presence: true
  validates :happened_at, presence: true
  validates :tags_id, presence: true

  belongs_to :user

  validate :check_tags_id_belong_to_user

  def check_tags_id_belong_to_user
    all_tag_ids = Tag.where(user_id: self.user_id).map(&:id)
    if self.tags_id & all_tag_ids != self.tags_id
      self.errors.add :tags_id, '不属于当前用户'
    end
  end

  def tags
    Tag.where(id: self.tags_id)
  end

  def self.default_scope
    where(deleted_at: nil)
  end
end