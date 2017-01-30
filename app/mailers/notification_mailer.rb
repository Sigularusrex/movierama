class NotificationMailer < ActionMailer::Base
  default from: "deliveroo_test@movierama.com"

  def new_vote(voter, movie, action)
    @action = action
    @voter = voter
    @movie = movie

    mail(to: @movie.user.email, subject: "#{@movie.title} has received a new vote")
  end

end
