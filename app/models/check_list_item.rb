# encoding: utf-8

class CheckListItem < ActiveRecord::Base
  #has_many :watcher_reports, dependent: :destroy

  has_ancestry

  #define INPUT_TEXT          0
  #define INPUT_NUMBER        1
  #define INPUT_DROPDOWN      2
  #define INPUT_SWITCH        3
  #define INPUT_PHOTO         4
  #define INPUT_VIDEO         5
  #define INPUT_COMMENT       6
  #define INPUT_CONSTANT      7
  #define INPUT_EMAIL         8
  #define INPUT_PHONE         9

  CONTROL_TYPES = %w(text number dropdown switch photo video comment constant email phone)

  def kind
    ActiveSupport::StringInquirer.new(control_type ? CONTROL_TYPES[control_type] : "")
  end
end