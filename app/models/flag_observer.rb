class FlagObserver < ActiveRecord::Observer
  observe :flag

  def after_save(flag)
    #TODO add code
  end
end
