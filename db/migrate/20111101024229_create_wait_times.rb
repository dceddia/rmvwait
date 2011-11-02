class CreateWaitTimes < ActiveRecord::Migration
  def self.up
    create_table :wait_times do |t|
      t.integer   :duration
      t.datetime  :reported_at
      t.integer   :branch_id
      t.string    :kind
      t.timestamps
    end
  end

  def self.down
    drop_table :wait_times
  end
end
