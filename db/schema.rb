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

ActiveRecord::Schema.define(version: 20170711005418) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "calendar_events", id: :string, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "company_id"
    t.string "notes_doc_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "reported_invalid"
    t.index ["company_id"], name: "index_calendar_events_on_company_id"
    t.index ["user_id"], name: "index_calendar_events_on_user_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "trello_id", null: false
    t.bigint "list_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_cards_on_company_id"
    t.index ["list_id"], name: "index_cards_on_list_id"
    t.index ["trello_id"], name: "index_cards_on_trello_id", unique: true
  end

  create_table "companies", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "domain"
    t.string "crunchbase_id"
    t.integer "team_id", null: false
    t.integer "capital_raised", default: 0, null: false
    t.text "description"
    t.index "to_tsvector('english'::regconfig, (name)::text)", name: "companies_to_tsvector_idx", using: :gin
    t.index ["crunchbase_id"], name: "index_companies_on_crunchbase_id", unique: true
    t.index ["domain"], name: "index_companies_on_domain", unique: true
    t.index ["name"], name: "index_companies_on_name"
    t.index ["team_id"], name: "index_companies_on_team_id"
  end

  create_table "companies_competitors", id: false, force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "competitor_id", null: false
    t.index ["company_id", "competitor_id"], name: "index_companies_competitors_on_company_id_and_competitor_id", unique: true
    t.index ["competitor_id", "company_id"], name: "index_companies_competitors_on_competitor_id_and_company_id", unique: true
  end

  create_table "companies_founders", id: false, force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "founder_id", null: false
    t.index ["company_id", "founder_id"], name: "index_companies_founders_on_company_id_and_founder_id", unique: true
    t.index ["founder_id", "company_id"], name: "index_companies_founders_on_founder_id_and_company_id", unique: true
  end

  create_table "companies_users", id: false, force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "user_id", null: false
    t.index ["company_id", "user_id"], name: "index_companies_users_on_company_id_and_user_id"
    t.index ["user_id", "company_id"], name: "index_companies_users_on_user_id_and_company_id"
  end

  create_table "competitors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "crunchbase_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["crunchbase_id"], name: "index_competitors_on_crunchbase_id", unique: true
    t.index ["name"], name: "index_competitors_on_name", unique: true
  end

  create_table "founders", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email"
    t.string "facebook"
    t.string "twitter"
    t.string "linkedin"
    t.string "homepage"
    t.string "crunchbase_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "logged_in_at"
    t.index ["crunchbase_id"], name: "index_founders_on_crunchbase_id", unique: true
    t.index ["email"], name: "index_founders_on_email", unique: true
    t.index ["facebook"], name: "index_founders_on_facebook", unique: true
    t.index ["homepage"], name: "index_founders_on_homepage", unique: true
    t.index ["linkedin"], name: "index_founders_on_linkedin", unique: true
    t.index ["twitter"], name: "index_founders_on_twitter", unique: true
  end

  create_table "investors", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email"
    t.string "crunchbase_id"
    t.string "role"
    t.bigint "competitor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index "first_name gist_trgm_ops", name: "trgm_first_name_indx", using: :gist
    t.index "last_name gist_trgm_ops", name: "trgm_last_name_indx", using: :gist
    t.index ["competitor_id"], name: "index_investors_on_competitor_id"
    t.index ["crunchbase_id"], name: "index_investors_on_crunchbase_id", unique: true
    t.index ["email"], name: "index_investors_on_email", unique: true
  end

  create_table "knowledges", id: :serial, force: :cascade do |t|
    t.text "body", null: false
    t.integer "user_id"
    t.string "ts", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id", null: false
    t.index ["team_id"], name: "index_knowledges_on_team_id"
    t.index ["ts"], name: "index_knowledges_on_ts", unique: true
    t.index ["user_id"], name: "index_knowledges_on_user_id"
  end

  create_table "lists", id: :serial, force: :cascade do |t|
    t.string "trello_id", null: false
    t.string "name", null: false
    t.float "pos", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "trello_board_id", null: false
    t.index ["pos", "trello_board_id"], name: "index_lists_on_pos_and_trello_board_id", unique: true
    t.index ["trello_id"], name: "index_lists_on_trello_id", unique: true
  end

  create_table "logged_events", id: :serial, force: :cascade do |t|
    t.text "reason", null: false
    t.integer "record_id", null: false
    t.integer "count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "data", default: [], null: false
    t.index ["reason", "record_id"], name: "index_logged_events_on_reason_and_record_id", unique: true
  end

  create_table "pitches", force: :cascade do |t|
    t.datetime "when", null: false
    t.datetime "decision"
    t.datetime "deadline"
    t.boolean "funded", default: false, null: false
    t.bigint "company_id", null: false
    t.string "snapshot"
    t.string "prevote_doc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_pitches_on_company_id"
    t.index ["prevote_doc"], name: "index_pitches_on_prevote_doc", unique: true
    t.index ["snapshot"], name: "index_pitches_on_snapshot", unique: true
  end

  create_table "target_investors", force: :cascade do |t|
    t.bigint "investor_id", null: false
    t.bigint "founder_id", null: false
    t.integer "stage", default: 0, null: false
    t.integer "tier", default: 1, null: false
    t.datetime "last_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["founder_id"], name: "index_target_investors_on_founder_id"
    t.index ["investor_id"], name: "index_target_investors_on_investor_id"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

  create_table "tweeters", id: :serial, force: :cascade do |t|
    t.string "username", null: false
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_tweeters_on_company_id"
    t.index ["username"], name: "index_tweeters_on_username", unique: true
  end

  create_table "tweets", id: :serial, force: :cascade do |t|
    t.bigint "twitter_id"
    t.integer "tweeter_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "shared", default: false, null: false
    t.index ["tweeter_id"], name: "index_tweets_on_tweeter_id"
    t.index ["twitter_id"], name: "index_tweets_on_twitter_id", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username", null: false
    t.datetime "inactive_since"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authentication_token"
    t.string "trello_id"
    t.string "slack_id"
    t.string "cached_name", null: false
    t.integer "team_id"
    t.string "access_token"
    t.string "refresh_token"
    t.datetime "logged_in_at", default: "2017-03-02 19:56:21", null: false
    t.index ["cached_name"], name: "index_users_on_cached_name", unique: true
    t.index ["slack_id"], name: "index_users_on_slack_id", unique: true
    t.index ["team_id"], name: "index_users_on_team_id"
    t.index ["trello_id"], name: "index_users_on_trello_id", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.integer "fit", null: false
    t.integer "team", null: false
    t.integer "product", null: false
    t.integer "market", null: false
    t.integer "overall"
    t.text "reason"
    t.boolean "final", default: false, null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "pitch_id"
    t.index ["pitch_id"], name: "index_votes_on_pitch_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "calendar_events", "companies"
  add_foreign_key "calendar_events", "users"
  add_foreign_key "cards", "companies"
  add_foreign_key "cards", "lists"
  add_foreign_key "companies", "teams"
  add_foreign_key "investors", "competitors"
  add_foreign_key "knowledges", "teams"
  add_foreign_key "knowledges", "users"
  add_foreign_key "pitches", "companies"
  add_foreign_key "target_investors", "founders"
  add_foreign_key "target_investors", "investors"
  add_foreign_key "users", "teams"
  add_foreign_key "votes", "pitches"
  add_foreign_key "votes", "users"
end
