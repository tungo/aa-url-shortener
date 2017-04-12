class Visit < ActiveRecord::Base

  belongs_to :user,
             primary_key: :id,
             foreign_key: :user_id,
             class_name: "User"

  belongs_to :shortened_url,
             primary_key: :id,
             foreign_key: :shortened_url_id,
             class_name: "ShortenedUrl"

  def self.record_visit!(user, shortened_url)
    self.create(user_id: user.id, shortened_url_id: shortened_url.id)
  end
end