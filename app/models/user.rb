# frozen_string_literal: true

class User < ApplicationRecord
  has_many :texts

  before_validation :ensure_username

  validates :name, :email, :password, presence: true
  validates :name, length: { in: 2..40 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def ensure_username
    self.name ||= email.split('@').first
  end

  devise(:database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable)
end
