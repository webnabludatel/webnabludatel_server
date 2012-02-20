# encoding: utf-8

class DeviceMessage < ActiveRecord::Base
  attr_accessible :kind, :device_id, :payload

  belongs_to :user
  belongs_to :user_message
  belongs_to :media_item

  after_create :process_message

  private

  def process_message
    case kind
      when 'media_item'
        update_media_item
      else
        update_user_message
    end
  end

  def update_user_message
    if user_message.blank?
      msg = user.user_messages.create(attributes_for_user_message)
      self.user_message = msg
      save!
    else
      user_message.update_attributes(attributes_for_user_message)
    end
  end

  def update_media_item
    if media_item.blank?
      item = user_message.media_items.create(attributes_for_media_item)
      self.media_item = item
      save!
    else
      media_item.update_attributes(attributes_for_media_item)
    end
  end

  def attributes_for_user_message
    data = JSON.parse(payload)
    {
      key: data['key'],
      value: data['value'],
      latitude: data['lat'],
      longitude: data['lng'],
      timestamp: Time.at(data['timestamp'].to_i)
    }
  end

  def attributes_for_media_item
    data = JSON.parse(payload)
    {
      url: data['url'],
      media_type: data['type'],
      timestamp: Time.at(data['timestamp'].to_i)
    }
  end
end
# == Schema Information
#
# Table name: device_messages
#
#  id              :integer         not null, primary key
#  payload         :text
#  user_id         :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  kind            :string(255)     default("message"), not null
#  device_id       :string(255)
#  media_item_id   :integer
#  user_message_id :integer
#
# Indexes
#
#  index_device_messages_on_user_id  (user_id)
#

