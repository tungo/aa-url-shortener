class Tagging < ActiveRecord::Base
  validates :tag_id, :url_id, presence: true

  belongs_to :tag_topic,
             primary_key: :id,
             foreign_key: :tag_id,
             class_name: :TagTopic

  belongs_to :shortened_url,
             primary_key: :id,
             foreign_key: :url_id,
             class_name: :ShortenedUrl
end
