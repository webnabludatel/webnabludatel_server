# encoding: utf-8

class Api::V1::BaseController < ApplicationController
  skip_before_filter :verify_authenticity_token

  around_filter :log_data
  before_filter :authenticate_user!

  protected

  def log_data
    body = env["rack.request.form_vars"]
    query = request.query_string
    auth = Authentication.for_device(params['device_id'])

    logger.debug "[API] Params: #{params.inspect}"
    logger.debug "[API] Query: #{query}"
    logger.debug "[API] Body: #{body}"

    if auth && auth.secret
      logger.debug "[API] Found #{auth.to_s}, owner: #{auth.user.email.presence || '<blank email>'}"
      logger.debug "[API] Secret: #{auth.secret}"
      logger.debug "[API] Our Digest: #{Digest::MD5.hexdigest(body + auth.secret)}"
    end

    yield

    logger.debug "[API] Result: [#{response.status}, #{response.content_type}, #{response.body}"
  end

  def render_result(result = {})
    render json: { status: :ok, result: result }
  end

  def render_error(errors = [])
    render json: { status: :error, errors: errors }
  end
end