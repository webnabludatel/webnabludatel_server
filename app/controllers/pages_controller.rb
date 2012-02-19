class PagesController < HighVoltage::PagesController
  skip_before_filter :authenticate
end
