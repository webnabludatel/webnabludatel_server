class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :check_user_validity, only: [:edit, :update]
end