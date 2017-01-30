class VotesController < ApplicationController
  def create
    authorize! :vote, _movie

    _voter.vote(_type)
    _notify_vote(current_user,_movie,_type)

    redirect_to root_path, notice: 'Vote cast'
  end

  def destroy
    authorize! :vote, _movie

    _voter.unvote
    redirect_to root_path, notice: 'Vote withdrawn'
  end

  private

  def _voter
    VotingBooth.new(current_user, _movie)
  end

  def _type
    case params.require(:t)
    when 'like' then :like
    when 'hate' then :hate
    else raise
    end
  end

  def _movie
    @_movie ||= Movie[params[:movie_id]]
  end

  # Sends an vote notification email to user
  def _notify_vote(voter, movie, action)
    # Check user has subscribed to notifications and has an email address
    if !movie.user.email.empty?
      NotificationMailer.delay.new_vote(voter, movie, action)
    end
  end

end
