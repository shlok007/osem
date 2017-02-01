class Resource < ActiveRecord::Base
  belongs_to :conference

  def quantity_left
    "#{quantity - used}/#{quantity}"
  end
end
