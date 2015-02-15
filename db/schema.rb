# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150215194850) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: true do |t|
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.boolean  "skip_mail"
    t.string   "addressee"
    t.string   "greeting"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number"
  end

  add_index "addresses", ["member_id"], name: "index_addresses_on_member_id", using: :btree

  create_table "members", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "email2"
    t.string   "cell_phone"
    t.string   "home_phone"
    t.string   "work_phone"
    t.string   "employer"
    t.string   "occupation"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "dues_paid"
    t.text     "clubs"
    t.string   "middle_name"
    t.integer  "primary_address_id"
  end

  add_index "members", ["primary_address_id"], name: "index_members_on_primary_address_id", using: :btree

  create_table "notes", force: true do |t|
    t.text     "content"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "member_id"
  end

  add_index "notes", ["member_id"], name: "index_notes_on_member_id", using: :btree

  create_table "payments", force: true do |t|
    t.date     "date"
    t.integer  "amount_cents",    default: 0,     null: false
    t.string   "amount_currency", default: "USD", null: false
    t.string   "kind"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "note"
    t.boolean  "dues"
    t.date     "deposit_date"
  end

  create_table "settings", force: true do |t|
    t.text "lookup"
    t.text "value"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
