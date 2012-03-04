class Admin::SosMessagesController < Admin::BaseController

  load_and_authorize_resource

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
    redirect_to partner_sos_message_path(@sos_message)
  end

end
