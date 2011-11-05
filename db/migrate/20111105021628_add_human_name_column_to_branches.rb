class AddHumanNameColumnToBranches < ActiveRecord::Migration
  def self.up
    add_column :branches, :human_name, :string
    Branch.all.each do |b|
      new_lowercase_name = b.name.gsub(/[^A-Za-z ]/, '').gsub(/ /, '_').downcase
      b.update_attributes(:human_name => b.name, :name => new_lowercase_name)
    end
  end

  def self.down
    Branch.all.each do |b|
      b.update_attributes(:name => b.human_name)
    end
    remove_column :branches, :human_name
  end
end
