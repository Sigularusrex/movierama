require 'rails_helper'
require 'spec_helper'

RSpec.describe NotificationMailer, type: :mailer do

  describe 'new_vote' do
    let(:mail) { NotificationMailer.new_vote("David", "email@example.com", "Movie Title", "Like") }

    it "renders the headers" do
      expect(mail.subject).to eq("Movie Title has received a new vote")
      expect(mail.to).to eq(["email@example.com"])
      expect(mail.from).to eq(["deliveroo_test@movierama.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("David has Liked your movie: Movie Title")
    end

  end
end