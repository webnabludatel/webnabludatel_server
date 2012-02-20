module MailListManager
  class << self

    def subscribe(email, list_name)
      hominid.list_subscribe(config.send(list_name).list_id, email.email, {}, 'html', false, true, true, false)
    rescue Hominid::APIError => e
      Rails.logger.error("Hominid API error: #{e.message}")
    end

    def unsubscribe(user, list_name)
      hominid.list_unsubscribe(config.send(list_name).list_id, user.email)
    end

    private

    def config
      @config ||= Settings.mailchimp
    end

    def hominid
      @hominid ||= Hominid::API.new config.api_key
    end

  end
end