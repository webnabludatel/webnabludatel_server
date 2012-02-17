require 'devise/strategies/base'

class Devise::Strategies::DeviceAuthenticatable < Devise::Strategies::Base
  def store?
    false
  end

  def valid?
    params[device_key] && params[digest_key]
  end

  def authenticate!
    auth = Authentication.find_for_device_authentication(params['device_id'])

    if validate(auth)
      params.delete(digest_key)
      success!(auth.user)
    elsif !halted?
      fail(:invalid)
    end
  end

  private

  def validate(auth)
    auth && auth.secret.present? && valid_digest?(auth.secret)
  end

  def valid_digest?(secret)
    digest == Digest::MD5.hexdigest(form_data + secret)
  end

  def form_data
    env["rack.request.form_vars"] || ""
  end

  def digest
    params[digest_key]
  end

  def device_key
    'device_id'
  end

  def digest_key
    'digest'
  end
end

Warden::Strategies.add(:device_authenticatable, Devise::Strategies::DeviceAuthenticatable)
