# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.destroy_all

carrefour_user = User.create!(email: "carrefour@gmail.com", password: "carrefour")


biocoop_user = User.create(email: "biocoop@gmail.com", password: "biocoop")

PnnsSecondGroup.create(name: 'Eggs', health_score: 4, environmental_score: 30)
PnnsSecondGroup.create(name: 'fruits', health_score: 5, environmental_score: 30)
PnnsSecondGroup.create(name: 'Waters and flavored waters', health_score: 5, environmental_score: 30)
PnnsSecondGroup.create(name: 'Vegetables', health_score: 5, environmental_score: 30)
PnnsSecondGroup.create(name: 'vegetables', health_score: 5, environmental_score: 30)
PnnsSecondGroup.create(name: 'Legumes', health_score: 5, environmental_score: 30)
PnnsSecondGroup.create(name: 'Potatoes', health_score: 5, environmental_score: 30)
PnnsSecondGroup.create(name: 'Nuts', health_score: 4, environmental_score: 30)
PnnsSecondGroup.create(name: 'Fruits', health_score: 5, environmental_score: 30)
PnnsSecondGroup.create(name: 'Dried fruits', health_score: 5, environmental_score: 27)
PnnsSecondGroup.create(name: 'Bread', health_score: 4, environmental_score: 18)
PnnsSecondGroup.create(name: 'Soups', health_score: 3, environmental_score: 18)
PnnsSecondGroup.create(name: 'Biscuits and cakes', health_score: -5, environmental_score: 15)
PnnsSecondGroup.create(name: 'Chocolate products', health_score: -5, environmental_score: 15)
PnnsSecondGroup.create(name: 'unknown', health_score: 0, environmental_score: 15)
PnnsSecondGroup.create(name: 'pastries', health_score: -2, environmental_score: 15)
PnnsSecondGroup.create(name: 'Salty and fatty products', health_score: -3, environmental_score: 9)
PnnsSecondGroup.create(name: 'Dressings and sauces', health_score: -4, environmental_score: 9)
PnnsSecondGroup.create(name: 'Teas and herbal teas and coffees', health_score: 2, environmental_score: 9)
PnnsSecondGroup.create(name: 'Milk and yogurt', health_score: 3, environmental_score: 9)
PnnsSecondGroup.create(name: 'Breakfast cereals', health_score: -1, environmental_score: 9)
PnnsSecondGroup.create(name: 'Pizza pies and quiche', health_score: -3, environmental_score: 9)
PnnsSecondGroup.create(name: 'Pizza pies and quiches', health_score: -3, environmental_score: 9)
PnnsSecondGroup.create(name: 'Sandwiches', health_score: -3, environmental_score: 9)
PnnsSecondGroup.create(name: 'Unsweetened beverages', health_score: -3, environmental_score: 9)
PnnsSecondGroup.create(name: 'Cereals', health_score: 4, environmental_score: 9)
PnnsSecondGroup.create(name: 'Fish and seafood', health_score: 4, environmental_score: 6)
PnnsSecondGroup.create(name: 'Alcoholic beverages', health_score: -5, environmental_score: 6)
PnnsSecondGroup.create(name: 'Cheese', health_score: -4, environmental_score: 6)
PnnsSecondGroup.create(name: 'Plant-based milk substitutes', health_score: 2, environmental_score: 6)
PnnsSecondGroup.create(name: 'Appetizers', health_score: -4, environmental_score: 3)
PnnsSecondGroup.create(name: 'Fruit juices', health_score: -3, environmental_score: 3)
PnnsSecondGroup.create(name: 'Dairy desserts', health_score: -3, environmental_score: 3)
PnnsSecondGroup.create(name: 'Fruit nectars', health_score: -3, environmental_score: 3)
PnnsSecondGroup.create(name: 'Ice cream', health_score: -4, environmental_score: 3)
PnnsSecondGroup.create(name: 'Sweetened beverages', health_score: -5, environmental_score: 3)
PnnsSecondGroup.create(name: 'One-dish meals', health_score: -4, environmental_score: 3)
PnnsSecondGroup.create(name: 'Artificially sweetened beverages', health_score: -5, environmental_score: 0)
PnnsSecondGroup.create(name: 'Offals', health_score: -5, environmental_score: 0)
PnnsSecondGroup.create(name: 'Sweets', health_score: -5, environmental_score: 0)
PnnsSecondGroup.create(name: 'Fats', health_score: -5, environmental_score: 0)
PnnsSecondGroup.create(name: 'Meat', health_score: -5, environmental_score: 0)
PnnsSecondGroup.create(name: 'Processed meat', health_score: -5, environmental_score: 0)

puts "Seed done"
