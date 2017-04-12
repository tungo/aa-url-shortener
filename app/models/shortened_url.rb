class ShortenedUrl < ActiveRecord::Base
  validates :user_id, presence: true, uniqueness: true

  belongs_to :submitter,
             primary_key: :id,
             foreign_key: :user_id,
             class_name: 'User'

  has_many :visits,
           primary_key: :id,
           foreign_key: :shortened_url_id,
           class_name: "ShortenedUrl"

  has_many :visitors,
           through: :visits,
           source: :user

  def self.random_code
    code = SecureRandom.urlsafe_base64
    while exists?(:short_url => code)
      code = SecureRandom.urlsafe_base64
    end
    code
  end

  def self.create_short_url(user, long_url)
    self.create!(user_id: user.id, long_url: long_url, short_url: self.random_code)
  end


end
