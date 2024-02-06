# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_02_06_055445) do
  create_table "elements", force: :cascade do |t|
    t.string "name"
    t.string "icon"
    t.string "description"
    t.boolean "default", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "discovered_by_id"
    t.string "discovered_uuid"
    t.index ["discovered_by_id"], name: "index_elements_on_discovered_by_id"
    t.index ["name"], name: "index_elements_on_name"
  end

  create_table "recipes", force: :cascade do |t|
    t.integer "left_element_id", null: false
    t.integer "right_element_id", null: false
    t.integer "result_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "discovered_by_id"
    t.string "discovered_uuid"
    t.index ["discovered_by_id"], name: "index_recipes_on_discovered_by_id"
    t.index ["left_element_id"], name: "index_recipes_on_left_element_id"
    t.index ["result_id"], name: "index_recipes_on_result_id"
    t.index ["right_element_id"], name: "index_recipes_on_right_element_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", default: "", null: false
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

  add_foreign_key "elements", "users", column: "discovered_by_id"
  add_foreign_key "recipes", "elements", column: "left_element_id"
  add_foreign_key "recipes", "elements", column: "result_id"
  add_foreign_key "recipes", "elements", column: "right_element_id"
  add_foreign_key "recipes", "users", column: "discovered_by_id"
end
