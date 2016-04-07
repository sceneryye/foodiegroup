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

ActiveRecord::Schema.define(version: 20160407041806) do

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",    limit: 255, null: false
    t.string   "data_content_type", limit: 255
    t.integer  "data_file_size",    limit: 4
    t.integer  "assetable_id",      limit: 4
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "body",        limit: 65535,             null: false
    t.integer  "user_id",     limit: 4
    t.integer  "event_id",    limit: 4
    t.integer  "groupbuy_id", limit: 4
    t.integer  "topic_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "agree",       limit: 4,     default: 0
    t.integer  "disagree",    limit: 4,     default: 0
  end

  add_index "comments", ["topic_id"], name: "index_comments_on_topic_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "event_type",         limit: 7,                                          null: false
    t.integer  "recommend",          limit: 4
    t.string   "pic_url",            limit: 500,                           default: ""
    t.string   "locale",             limit: 255
    t.datetime "start_time",                                                            null: false
    t.datetime "end_time",                                                              null: false
    t.integer  "user_id",            limit: 4,                                          null: false
    t.integer  "limited_people",     limit: 4
    t.decimal  "price",                           precision: 10, scale: 2
    t.string   "pay_type",           limit: 7
    t.string   "name",               limit: 45
    t.string   "mobile",             limit: 45
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "participants_count", limit: 4,                             default: 0
    t.integer  "comments_count",     limit: 4,                             default: 0
    t.integer  "agree",              limit: 4,                             default: 0
    t.integer  "disagree",           limit: 4,                             default: 0
    t.string   "address",            limit: 255
    t.string   "x_coordinate",       limit: 255
    t.string   "y_coordinate",       limit: 255
    t.string   "zh_title",           limit: 255
    t.string   "zh_body",            limit: 5000
    t.string   "en_title",           limit: 255
    t.string   "en_body",            limit: 5000
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "events_back", force: :cascade do |t|
    t.string   "title",              limit: 255,                                          null: false
    t.string   "event_type",         limit: 7,                                            null: false
    t.integer  "recommend",          limit: 4
    t.string   "pic_url",            limit: 500,                                          null: false
    t.text     "body",               limit: 65535,                                        null: false
    t.datetime "start_time",                                                              null: false
    t.datetime "end_time",                                                                null: false
    t.integer  "user_id",            limit: 4,                                            null: false
    t.integer  "limited_people",     limit: 4,                              default: 0
    t.string   "goods_unit",         limit: 45
    t.decimal  "price",                            precision: 10, scale: 2
    t.string   "pay_type",           limit: 7
    t.decimal  "goods_small_than",                 precision: 20, scale: 2, default: 0.0
    t.decimal  "goods_big_than",                   precision: 20, scale: 2
    t.string   "name",               limit: 45
    t.string   "mobile",             limit: 45
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "participants_count", limit: 4,                              default: 0
    t.integer  "comments_count",     limit: 4,                              default: 0
    t.integer  "agree",              limit: 4,                              default: 0
    t.integer  "disagree",           limit: 4,                              default: 0
    t.string   "locale",             limit: 255
  end

  add_index "events_back", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "forums", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  add_index "forums", ["name"], name: "index_forums_on_name", unique: true, using: :btree

  create_table "groupbuys", force: :cascade do |t|
    t.decimal  "market_price",                    precision: 10, scale: 2
    t.decimal  "price",                           precision: 10, scale: 2
    t.decimal  "weight",                          precision: 10, scale: 2
    t.integer  "logistic_id",        limit: 4
    t.integer  "status",             limit: 1,                             default: 1
    t.datetime "start_time",                                                              null: false
    t.datetime "end_time",                                                                null: false
    t.integer  "user_id",            limit: 4
    t.integer  "recommend",          limit: 4,                             default: 0
    t.string   "pic_url",            limit: 500,                           default: ""
    t.string   "locale",             limit: 45,                            default: "zh"
    t.string   "goods_unit",         limit: 45
    t.string   "pay_type",           limit: 7
    t.decimal  "goods_minimal",                   precision: 20, scale: 2
    t.decimal  "goods_maximal",                   precision: 20, scale: 2
    t.string   "name",               limit: 45
    t.string   "mobile",             limit: 45
    t.integer  "comments_count",     limit: 4,                             default: 0
    t.integer  "participants_count", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "groupbuy_price",                  precision: 10, scale: 2
    t.string   "en_title",           limit: 255
    t.string   "en_body",            limit: 5000
    t.string   "zh_title",           limit: 255
    t.string   "zh_body",            limit: 5000
    t.boolean  "online",                                                   default: true
    t.string   "goods_size",         limit: 255
    t.string   "goods_bbd",          limit: 255
  end

  add_index "groupbuys", ["user_id"], name: "index_groupbuys_on_user_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string  "name",       limit: 255, null: false
    t.string  "group_desc", limit: 255
    t.integer "user_id",    limit: 4
  end

  add_index "groups", ["name"], name: "index_groups_on_name", unique: true, using: :btree
  add_index "groups", ["user_id"], name: "index_groups_on_user_id", using: :btree

  create_table "logistics", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "default",    limit: 1
  end

  add_index "logistics", ["user_id"], name: "index_logistics_on_user_id", using: :btree

  create_table "logistics_items", force: :cascade do |t|
    t.integer  "logistic_id", limit: 4
    t.string   "areas",       limit: 255
    t.integer  "price",       limit: 4
    t.integer  "each_add",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logistics_items", ["logistic_id"], name: "index_logistics_items_on_logistic_id", using: :btree

  create_table "participants", force: :cascade do |t|
    t.integer  "user_id",         limit: 4,                                         null: false
    t.integer  "event_id",        limit: 4
    t.integer  "groupbuy_id",     limit: 4
    t.string   "name",            limit: 45,                                        null: false
    t.string   "mobile",          limit: 45,                                        null: false
    t.string   "address",         limit: 255
    t.integer  "status",          limit: 4,                             default: 0
    t.decimal  "amount",                       precision: 10, scale: 2
    t.integer  "freightage",      limit: 4
    t.decimal  "discount",                     precision: 10, scale: 2
    t.string   "area",            limit: 255
    t.integer  "discount_id",     limit: 4
    t.integer  "quantity",        limit: 4
    t.string   "remark",          limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_pay",      limit: 4,                             default: 0
    t.integer  "status_ship",     limit: 4,                             default: 0
    t.string   "delivery_time",   limit: 255
    t.string   "tracking_number", limit: 255
  end

  create_table "photos", force: :cascade do |t|
    t.integer  "groupbuy_id",  limit: 4
    t.integer  "event_id",     limit: 4
    t.string   "image",        limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "name",         limit: 255
    t.string   "size",         limit: 255
    t.string   "content_type", limit: 255
    t.integer  "comment_id",   limit: 4
    t.integer  "topic_id",     limit: 4
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "url",        limit: 255
    t.integer  "rate",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale",     limit: 255
  end

  create_table "topics", force: :cascade do |t|
    t.string   "title",          limit: 255,               null: false
    t.text     "body",           limit: 65535,             null: false
    t.integer  "comments_count", limit: 4,     default: 0
    t.integer  "user_id",        limit: 4
    t.integer  "forum_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "agree",          limit: 4,     default: 0
    t.integer  "disagree",       limit: 4,     default: 0
    t.integer  "recommend",      limit: 4
    t.string   "zh_title",       limit: 255
    t.string   "zh_body",        limit: 5000
    t.string   "en_title",       limit: 255
    t.string   "en_body",        limit: 5000
  end

  add_index "topics", ["forum_id"], name: "index_topics_on_forum_id", using: :btree
  add_index "topics", ["user_id"], name: "index_topics_on_user_id", using: :btree

  create_table "user_addresses", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 45,  null: false
    t.string   "mobile",     limit: 45
    t.string   "address",    limit: 500, null: false
    t.string   "area",       limit: 255
    t.integer  "default",    limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_addresses", ["user_id"], name: "index_user_addresses_on_user_id", using: :btree

  create_table "user_insterests", force: :cascade do |t|
    t.integer  "user_id",        limit: 4, null: false
    t.string   "insterest_type", limit: 5, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_instersts", force: :cascade do |t|
    t.integer  "user_id",        limit: 4, null: false
    t.string   "insterest_type", limit: 5, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",        limit: 45,  default: ""
    t.string   "name",            limit: 45
    t.integer  "group_id",        limit: 4
    t.string   "mobile",          limit: 45
    t.string   "email",           limit: 255
    t.string   "sex",             limit: 1,   default: "0"
    t.string   "password_digest", limit: 255, default: ""
    t.string   "role",            limit: 1,   default: "0"
    t.string   "avatar",          limit: 500
    t.string   "nickname",        limit: 255
    t.string   "profession",      limit: 45
    t.string   "location",        limit: 45
    t.integer  "comments_count",  limit: 4
    t.integer  "events_count",    limit: 4
    t.integer  "topics_count",    limit: 4
    t.string   "weixin_openid",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "agree",           limit: 4,   default: 0
    t.integer  "disagree",        limit: 4,   default: 0
  end

  add_index "users", ["group_id"], name: "index_topics_on_forum_id", using: :btree

  create_table "users_votings", id: false, force: :cascade do |t|
    t.integer "user_id",   limit: 4, null: false
    t.integer "voting_id", limit: 4, null: false
  end

  add_index "users_votings", ["user_id", "voting_id"], name: "index_users_votings_on_user_id_and_voting_id", using: :btree
  add_index "users_votings", ["voting_id", "user_id"], name: "index_users_votings_on_voting_id_and_user_id", using: :btree

  create_table "vote_products", force: :cascade do |t|
    t.string   "picture",    limit: 255
    t.string   "title",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "vote_product_id", limit: 4
    t.integer  "voting_id",       limit: 4
    t.integer  "votes",           limit: 4, default: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "votings", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "end_time"
  end

  create_table "wechats", force: :cascade do |t|
    t.string   "auth_access_token",             limit: 255
    t.integer  "auth_access_token_expires_at",  limit: 4
    t.string   "auth_refresh_token",            limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "auth_refresh_token_expires_at", limit: 4
    t.string   "access_token",                  limit: 255
    t.integer  "access_token_expires_at",       limit: 4
    t.string   "jsapi_ticket",                  limit: 255
    t.integer  "jsapi_ticket_expires_at",       limit: 4
  end

end
