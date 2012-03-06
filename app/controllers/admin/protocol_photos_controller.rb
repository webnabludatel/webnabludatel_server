# encoding: utf-8

class Admin::ProtocolPhotosController < Admin::BaseController
  load_and_authorize_resource

  def index
    @protocol_photos = ProtocolPhoto.pending.includes(user_location: :commission).includes(user_location: :user).order("id").page(params[:page])
  end

  def update
    @protocol_photo = ProtocolPhoto.find params[:id]

    if @protocol_photo.update_attributes status: params[:status]
      render :js => "$('##{dom_id(@protocol_photo, :status)}').html('#{@protocol_photo.status}');$('##{dom_id(@protocol_photo, :controls)}').html('<p>Сохранено</p>');"
    else
      render :js => "$('##{dom_id(@protocol_photo, :controls)}').append('<p>ERROR: #{@protocol_photo.errors.full_messages.inspect}</p>');"
    end
  end
end