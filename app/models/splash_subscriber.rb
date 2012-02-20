class SplashSubscriber < ActiveRecord::Base
  validates :email, :length => { :within => 3..60 }, :format => { :with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i }, :uniqueness => true

  after_create :subscribe_in_mailchimp

  def subscribe
    MailListManager.subscribe self, "splash"
  end

  def unsubscribe
    MailListManager.unsubscribe self, "splash"
  end

  private
  def subscribe_in_mailchimp
    self.delay.subscribe
  end
end