# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

location_levels = LocationLevel.create([{ name: 'Country', level: 10, description: 'A country'},
                                        { name: 'City', level: 20, description: 'A city'},
                                        { name: 'Data center', level: 30, description: 'A data center'},
                                        { name: 'Rack', level: 40, description: 'A rack'},
                                        { name: 'Power feed', level: 50, description: 'Power feed'}])
