# Monkey patches the Cell::ViewModel class to return false on #is_haml?
# This is done since we're using slim (apparently #is_haml? isn't part of the Tilt API)
module ViewModel
  def is_haml?
    false
  end
end
module Cell
  class ViewModel
    def is_haml?
      false
    end
  end
end