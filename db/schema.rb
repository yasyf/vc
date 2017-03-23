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

ActiveRecord::Schema.define(version: 20170323194208) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calendar_events", id: :string, force: :cascade do |t|
    t.integer  "user_id",                        null: false
    t.integer  "company_id"
    t.string   "notes_doc_link"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "invalid",        default: false, null: false
    t.index ["company_id"], name: "index_calendar_events_on_company_id", using: :btree
    t.index ["user_id"], name: "index_calendar_events_on_user_id", using: :btree
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name",                             null: false
    t.string   "trello_id",                        null: false
    t.date     "pitch_on"
    t.datetime "decision_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.date     "deadline"
    t.integer  "list_id"
    t.boolean  "override_quorum",  default: false, null: false
    t.string   "snapshot_link"
    t.string   "domain"
    t.string   "crunchbase_id"
    t.integer  "team_id",                          null: false
    t.integer  "capital_raised",   default: 0,     null: false
    t.text     "description"
    t.boolean  "cached_funded",    default: false, null: false
    t.string   "prevote_doc_link"
    t.index ["crunchbase_id"], name: "index_companies_on_crunchbase_id", unique: true, using: :btree
    t.index ["domain"], name: "index_companies_on_domain", unique: true, using: :btree
    t.index ["list_id"], name: "index_companies_on_list_id", using: :btree
    t.index ["name"], name: "index_companies_on_name", using: :btree
    t.index ["snapshot_link"], name: "index_companies_on_snapshot_link", unique: true, using: :btree
    t.index ["team_id"], name: "index_companies_on_team_id", using: :btree
    t.index ["trello_id"], name: "index_companies_on_trello_id", unique: true, using: :btree
  end

  create_table "companies_competitors", id: false, force: :cascade do |t|
    t.integer "company_id",    null: false
    t.integer "competitor_id", null: false
    t.index ["company_id", "competitor_id"], name: "index_companies_competitors_on_company_id_and_competitor_id", unique: true, using: :btree
    t.index ["competitor_id", "company_id"], name: "index_companies_competitors_on_competitor_id_and_company_id", unique: true, using: :btree
  end

  create_table "companies_users", id: false, force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "user_id",    null: false
    t.index ["company_id", "user_id"], name: "index_companies_users_on_company_id_and_user_id", using: :btree
    t.index ["user_id", "company_id"], name: "index_companies_users_on_user_id_and_company_id", using: :btree
  end

  create_table "competitors", force: :cascade do |t|
    t.string   "name"
    t.string   "crunchbase_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["crunchbase_id"], name: "index_competitors_on_crunchbase_id", unique: true, using: :btree
    t.index ["name"], name: "index_competitors_on_name", unique: true, using: :btree
  end

  create_table "knowledges", force: :cascade do |t|
    t.text     "body",       null: false
    t.integer  "user_id"
    t.string   "ts",         null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "team_id",    null: false
    t.index ["team_id"], name: "index_knowledges_on_team_id", using: :btree
    t.index ["ts"], name: "index_knowledges_on_ts", unique: true, using: :btree
    t.index ["user_id"], name: "index_knowledges_on_user_id", using: :btree
  end

  create_table "lists", force: :cascade do |t|
    t.string   "trello_id",       null: false
    t.string   "name",            null: false
    t.float    "pos",             null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "trello_board_id", null: false
    t.index ["pos", "trello_board_id"], name: "index_lists_on_pos_and_trello_board_id", unique: true, using: :btree
    t.index ["trello_id"], name: "index_lists_on_trello_id", unique: true, using: :btree
  end

  create_table "logged_events", force: :cascade do |t|
    t.text     "reason",                  null: false
    t.integer  "record_id",               null: false
    t.integer  "count",      default: 0,  null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.json     "data",       default: [], null: false
    t.index ["reason", "record_id"], name: "index_logged_events_on_reason_and_record_id", unique: true, using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_teams_on_name", unique: true, using: :btree
  end

  create_table "tweeters", force: :cascade do |t|
    t.string   "username",   null: false
    t.integer  "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_tweeters_on_company_id", using: :btree
    t.index ["username"], name: "index_tweeters_on_username", unique: true, using: :btree
  end

  create_table "tweets", force: :cascade do |t|
    t.bigint   "twitter_id"
    t.integer  "tweeter_id",                 null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "shared",     default: false, null: false
    t.index ["tweeter_id"], name: "index_tweets_on_tweeter_id", using: :btree
    t.index ["twitter_id"], name: "index_tweets_on_twitter_id", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",                                             null: false
    t.datetime "inactive_since"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.string   "authentication_token"
    t.string   "cached_name",                                          null: false
    t.string   "trello_id"
    t.string   "slack_id"
    t.integer  "team_id"
    t.string   "access_token"
    t.string   "refresh_token"
    t.datetime "logged_in_at",         default: '2017-03-02 19:43:42', null: false
    t.index ["cached_name"], name: "index_users_on_cached_name", unique: true, using: :btree
    t.index ["slack_id"], name: "index_users_on_slack_id", unique: true, using: :btree
    t.index ["team_id"], name: "index_users_on_team_id", using: :btree
    t.index ["trello_id"], name: "index_users_on_trello_id", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
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

  add_foreign_key "calendar_events", "companies"
  add_foreign_key "calendar_events", "users"
  add_foreign_key "companies", "lists"
  add_foreign_key "companies", "teams"
  add_foreign_key "knowledges", "teams"
  add_foreign_key "knowledges", "users"
  add_foreign_key "users", "teams"
  add_foreign_key "votes", "users"
end
