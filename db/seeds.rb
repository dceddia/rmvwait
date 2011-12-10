# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

names = [
  'Attleboro',
  'Boston',
  'Braintree',
  'Brockton',
  'Chicopee',
  'Danvers',
  'Easthampton',
  'Fall River',
  'Greenfield',
  'Haverhill',
  'Lawrence',
  'Leominster',
  'Lowell',
  'Martha\'s Vineyard',
  'Milford',
  'Nantucket',
  'Natick',
  'New Bedford',
  'North Adams',
  'Pittsfield',
  'Plymouth',
  'Revere',
  'Roslindale',
  'South Yarmouth',
  'Springfield',
  'Taunton',
  'Watertown',
  'Wilmington',
  'Worcester']
  
names.each do |name|
  lower_name = name.gsub(/[^A-Za-z ]/, '').gsub(/ /, '_').downcase
  Branch.create(:name => lower_name, :human_name => name, :active => true)
end
