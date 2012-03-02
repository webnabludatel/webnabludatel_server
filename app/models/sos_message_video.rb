# encoding: utf-8

class SosMessageVideo < ActiveRecord::Base
  belongs_to :sos_message
  belongs_to :media_item
end