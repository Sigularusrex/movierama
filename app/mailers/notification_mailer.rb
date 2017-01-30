class NotificationMailer < ActionMailer::Base
  default from: "deliveroo_test@movierama.com"

  def new_vote(voter, recipient, movie, action)
    @action = action
    @voter = voter
    @movie = movie

    mail(to: recipient, subject: "#{movie} has received a new vote")
  end

end
