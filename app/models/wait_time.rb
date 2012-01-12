class WaitTime < ActiveRecord::Base
  belongs_to :branch
  
  def reported_at_js
    reported_at.to_i * 1000.0
  end
  
  def reported_at_js_local
    (reported_at.to_i + Time.zone.utc_offset) * 1000.0
  end
end
