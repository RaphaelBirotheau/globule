# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.


ActiveRecord::Schema.define(version: 2019_08_28_102700) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "order_items", force: :cascade do |t|
    t.string "discount"
    t.integer "quantity"
    t.integer "price"
    t.bigint "order_id"
    t.bigint "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "purchase_date"
    t.string "nutrition_score_repartition"
    t.string "nutrition_repartition"
    t.string "nova_repartition"
    t.string "label_repartition"
    t.string "packaging_repartition"
    t.string "product_category_repartition"
    t.string "product_sub_category_repartition"
    t.string "country_origin_repartion"
    t.string "additives_repartition"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "nutrition_grades_tags"
    t.string "nova_group"
    t.string "allergens_tags"
    t.string "generic_name_fr"
    t.string "image_front_url"
    t.string "code"
    t.string "categories_hierarchy"
    t.string "additives_tags"
    t.string "brands"
    t.string "stores_tags"
    t.string "labels_tags"
    t.string "countries_tags"
    t.string "ingredients_tags"
    t.string "packaging_tags"
    t.string "product_quantity"
    t.string "serving_quantity"
    t.string "ingredients_analysis_tags"
    t.string "nutriments"
    t.string "pnns_group_1"
    t.string "pnns_group_2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_profiles", force: :cascade do |t|
    t.string "nutrition_score_repartition"
    t.string "nutrition_repartition"
    t.string "nova_repartition"
    t.string "label_repartition"
    t.string "packaging_repartition"
    t.string "product_category_repartition"
    t.string "product_sub_category_repartition"
    t.string "country_origin_repartion"
    t.string "additives_repartition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "family_size"
    t.integer "children"
    t.string "loyalty"
    t.string "city"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
end
