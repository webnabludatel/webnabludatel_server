class MediaItem < ActiveRecord::Base
  belongs_to :user_message

  after_create :process

  private
    def process
      analyzer = MediaItemAnalyzer.new self
      analyzer.process!
    end
end
# == Schema Information
#
# Table name: media_items
#
#  id              :integer         not null, primary key
#  user_message_id :integer
#  url             :string(255)
#  media_type      :string(255)
#  timestamp       :datetime
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

