class Resource < ActiveRecord::Base
  belongs_to :conference
  validate :used_less_than_quantity

  private

  def used_less_than_quantity
    errors.add(:used, 'cannot be less than total quantity') unless used <= quantity
  end
end
