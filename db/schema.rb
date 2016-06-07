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

ActiveRecord::Schema.define(version: 20160607172710) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "trello_id",   null: false
    t.date     "pitch_on"
    t.datetime "decision_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "companies", ["name"], name: "index_companies_on_name", using: :btree
  add_index "companies", ["trello_id"], name: "index_companies_on_trello_id", using: :btree

  create_table "knowledges", force: :cascade do |t|
    t.text     "body",       null: false
    t.integer  "user_id"
    t.string   "ts",         null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "knowledges", ["ts"], name: "index_knowledges_on_ts", using: :btree
  add_index "knowledges", ["user_id"], name: "index_knowledges_on_user_id", using: :btree

  create_table "logged_errors", force: :cascade do |t|
    t.text     "reason",                 null: false
    t.integer  "record_id",              null: false
    t.integer  "count",      default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "logged_errors", ["reason", "record_id"], name: "index_logged_errors_on_reason_and_record_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",       null: false
    t.datetime "inactive_since"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "fit",                        null: false
    t.integer  "team",                       null: false
    t.integer  "product",                    null: false
    t.integer  "market",                     null: false
    t.integer  "overall"
    t.text     "reason"
    t.boolean  "final",      default: false, null: false
    t.integer  "user_id"
    t.integer  "company_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "votes", ["company_id", "user_id", "final"], name: "index_votes_on_company_id_and_user_id_and_final", unique: true, using: :btree
  add_index "votes", ["company_id"], name: "index_votes_on_company_id", using: :btree
  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

  add_foreign_key "knowledges", "users"
  add_foreign_key "votes", "users"
end
