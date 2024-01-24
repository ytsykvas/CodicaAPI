class Task < ApplicationRecord
  belongs_to :project
  enum status: { todo: 0, in_progress: 1, completed: 2 }

  validates :name, presence: true, length: { maximum: 50 }
  validates :description, presence: true
  validates :status, presence: true
end
