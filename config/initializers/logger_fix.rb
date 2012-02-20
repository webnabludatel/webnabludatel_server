# Temporary workaround for https://github.com/rails/rails/issues/4277
# TODO: remove this after upgrading to rails 3.2.2
Rails.logger.instance_variable_get(:@logger).instance_variable_get(:@log_dest).sync = true if Rails.logger
