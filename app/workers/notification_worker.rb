class NotificationWorker
  include Sidekiq::Worker

  def perform(voter, recipient, movie, action)
    NotificationMailer.new_vote(voter, recipient, movie, action).deliver
  end
end
