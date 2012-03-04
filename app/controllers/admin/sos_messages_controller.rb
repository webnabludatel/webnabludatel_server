class Admin::SosMessagesController < Admin::BaseController

  load_and_authorize_resource
  has_scope :active, {:boolean => true}

  def index
    @sos_messages = SosMessage.order("timestamp DESC").page params[:page]
  end

  def edit
    @sos_message = SosMessage.find(params[:id])
  end

  def update
    @sos_message = SosMessage.find(params[:id])
    @sos_message.status = params[:sos_message][:status]
    @sos_message.last_changed_user = current_user
    @sos_message.save
    redirect_to admin_sos_messages_path
  end

end
