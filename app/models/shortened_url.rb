class ShortenedUrl < ActiveRecord::Base
  validates :user_id, presence: true
  validate :no_spamming
  validate :nonpremium_max

  belongs_to :submitter,
             primary_key: :id,
             foreign_key: :user_id,
             class_name: 'User'

  has_many :visits,
           primary_key: :id,
           foreign_key: :shortened_url_id,
           class_name: "Visit"

  has_many :visitors,
           through: :visits,
           source: :user

  has_many :taggings,
           primary_key: :id,
           foreign_key: :url_id,
           class_name: :Tagging

  has_many :tag_topics,
           through: :taggings,
           source: :tag_topic

  def self.random_code
    code = SecureRandom.urlsafe_base64
    while exists?(:short_url => code)
      code = SecureRandom.urlsafe_base64
    end
    code
  end

  def self.create_for_user_and_long_url!(user, long_url)
    self.create!(user_id: user.id, long_url: long_url, short_url: self.random_code)
  end

  def self.prune(n)
    # valid_id = Visit.where("created_at > ?", n.minutes.ago)
    # .map(&:shortened_url_id).uniq
    # self.delete_all(['id NOT IN (?)', valid_id])
    sql = <<-SQL
      DELETE FROM
        shortened_urls
      WHERE
        id NOT IN (
          SELECT DISTINCT
            shortened_url_id
          FROM
            visits
          WHERE
            created_at >  '#{n.minutes.ago}'
          ) AND id NOT IN (
            SELECT DISTINCT
              shortened_urls.id
            FROM
              shortened_urls
              JOIN users ON shortened_urls.user_id = users.id
            WHERE
              premium = true
          )
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visits.select(:user_id).distinct.count
  end

  def num_recent_uniques
    visits.select(:user_id).distinct.where("created_at > ?", 20.minutes.ago).count
  end

  private
  def no_spamming
    if submitter.submitted_urls.where("created_at > ?", 1.minutes.ago).count > 5
      errors[:base] << "STOP SPAMMING!"
    end
  end

  def nonpremium_max
    if submitter.submitted_urls.count > 1 && !submitter.premium
      errors[:base] << "$ Pay to add more URLS $"
    end
  end
end
