require "spec_helper"
RSpec.describe ThankYouMailer do
  describe 'thank you' do
    let(:user) { FactoryGirl.create(:donor_user) }
    let(:mail) { ThankYouMailer.thank_you_email(user) }

      # Test the body of the sent email contains what we expect it to
    it 'renders the sender' do
      expect(ApplicationMailer.default[:from]).to eql((mail.from)[0])
    end
      it 'addresses to proper recipient' do
      expect((mail.to)[0]).to eql(user.email)
    end
    it 'renders correct subject' do
        expect(mail.subject).to eql(Rails.configuration.thank_you_email_subject)
    end
    it 'renders correct body' do
      expect(mail.body).to include("Wediko's secret snowman has always relied on your kindness, ")
    end
  end
end
