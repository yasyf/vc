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

ActiveRecord::Schema.define(version: 20160612002622) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "trello_id",   null: false
    t.date     "pitch_on"
    t.datetime "decision_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.date     "deadline"
    t.integer  "list_id"
    t.index ["list_id"], name: "index_companies_on_list_id", using: :btree
    t.index ["name"], name: "index_companies_on_name", using: :btree
    t.index ["trello_id"], name: "index_companies_on_trello_id", using: :btree
  end

  create_table "knowledges", force: :cascade do |t|
    t.text     "body",       null: false
    t.integer  "user_id"
    t.string   "ts",         null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ts"], name: "index_knowledges_on_ts", using: :btree
    t.index ["user_id"], name: "index_knowledges_on_user_id", using: :btree
  end

  create_table "lists", force: :cascade do |t|
    t.string   "trello_id",  null: false
    t.string   "name",       null: false
    t.float    "pos",        null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_lists_on_name", using: :btree
    t.index ["trello_id"], name: "index_lists_on_trello_id", using: :btree
  end

  create_table "logged_events", force: :cascade do |t|
    t.text     "reason",                 null: false
    t.integer  "record_id",              null: false
    t.integer  "count",      default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["reason", "record_id"], name: "index_logged_events_on_reason_and_record_id", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",       null: false
    t.datetime "inactive_since"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["username"], name: "index_users_on_username", using: :btree
  end

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
    t.index ["company_id", "user_id", "final"], name: "index_votes_on_company_id_and_user_id_and_final", unique: true, using: :btree
    t.index ["company_id"], name: "index_votes_on_company_id", using: :btree
    t.index ["user_id"], name: "index_votes_on_user_id", using: :btree
  end

  add_foreign_key "companies", "lists"
  add_foreign_key "knowledges", "users"
  add_foreign_key "votes", "users"
end
