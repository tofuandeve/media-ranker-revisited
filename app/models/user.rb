class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :works, dependent: :nullify
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true
  validates :uid, presence: true
  validates :provider, presence: true

  def self.build_from_github(auth_hash)
    user = User.new
    user.uid = auth_hash[:uid]
    user.provider = "github"
    user.name = auth_hash["info"]["name"]
    user.username = auth_hash["info"]["nickname"]
    user.email = auth_hash["info"]["email"]

    return user
  end
end
