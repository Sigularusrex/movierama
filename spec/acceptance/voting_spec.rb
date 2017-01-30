require 'rails_helper'
require 'capybara/rails'
require 'support/pages/movie_list'
require 'support/pages/movie_new'
require 'support/with_user'
require 'sidekiq/testing'

RSpec.describe 'vote on movies', type: :feature do

  let(:page) { Pages::MovieList.new }

  before do
    # clear all jobs from worker
    NotificationWorker.drain

    author1 = User.create(
      uid:   'null|12345',
      name:  'Bob',
      email: 'bob@example.com'
    )
    Movie.create(
      title:        'Empire strikes back',
      description:  'Who\'s scruffy-looking?',
      date:         '1980-05-21',
      user:         author1
    )
    author2 = User.create(
        uid:   'null|22345',
        name:  'Bobby'
    )
    Movie.create(
        title:        'Return of the Jedi',
        description:  'Description for ROTJ',
        date:         '1980-05-21',
        user:         author2
    )
  end

  context 'when logged out' do
    it 'cannot vote' do
      page.open
      expect {
        page.like('Empire strikes back')
      }.to raise_error(Capybara::ElementNotFound)
    end
  end

  context 'when logged in' do
    with_logged_in_user

    before { page.open }

    it 'can like' do
      page.like('Empire strikes back')

      notification_queue(1)
      expect(page).to have_vote_message
    end

    it 'can hate' do
      page.hate('Empire strikes back')

      notification_queue(1)
      expect(page).to have_vote_message
    end

    it 'can unlike' do
      page.like('Empire strikes back')
      notification_queue(1)

      page.unlike('Empire strikes back')
      notification_queue(0)

      expect(page).to have_unvote_message
    end

    it 'can unhate' do
      page.hate('Empire strikes back')
      notification_queue(1)

      page.unhate('Empire strikes back')
      notification_queue(0)

      expect(page).to have_unvote_message
    end

    it 'cannot like twice' do
      expect {
        2.times { page.like('Empire strikes back') }
      }.to raise_error(Capybara::ElementNotFound)
    end

    it 'cannot like own movies' do
      Pages::MovieNew.new.open.submit(
        title:       'The Party',
        date:        '1969-08-13',
        description: 'Birdy nom nom')
      page.open
      expect {
        page.like('The Party')
      }.to raise_error(Capybara::ElementNotFound)
    end

    it 'cannot notify without email' do
        page.like('Return of the Jedi')

        notification_queue(0)
        expect(page).to have_vote_message
    end
  end

  def notification_queue(should_equal)
    assert_equal should_equal, NotificationWorker.jobs.size
    NotificationWorker.drain
  end

end



