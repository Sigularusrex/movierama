class User < BaseModel
  include Ohm::Timestamps

  attribute :name

  # Unique identifier for this user, in the form "{provider}|{provider-id}"
  attribute :uid
  index     :uid
  unique    :uid

  # Email address
  attribute :email
  unique    :email

  # Session token
  attribute :token
  index     :token

  # Submitted movies
  collection :movies, :Movie
end
