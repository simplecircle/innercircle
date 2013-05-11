# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Vertical.create([
  { name: 'eCommerce' },
  { name: 'Internet' },
  { name: 'Gaming' },
  { name: 'Marketing / PR / Branding' },
  { name: 'Entertainment / Media' },
  { name: 'Education' },
  { name: 'Healthcare' },
  { name: 'B2B Software / Saas' },
  { name: 'Finance' },
  { name: 'Government / Politics' },
  { name: 'Fashion' },
  { name: 'Travel' },
  { name: 'Social Impact' }
])

CompanyDept.create([{name: 'operations'}, {name: 'creative'}, {name: 'sales & marketing'}, {name: 'technology'}])




ActsAsTaggableOn::Tag.create([{name: 'Rails'}])