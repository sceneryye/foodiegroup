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

ActiveRecord::Schema.define(version: 2015122006472224) do

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
    t.integer  "topic_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "agree",       limit: 4,     default: 0
    t.integer  "disagree",    limit: 4,     default: 0
    t.integer  "groupbuy_id", limit: 4
  end

  add_index "comments", ["topic_id"], name: "index_comments_on_topic_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "title",              limit: 255,                                          null: false
    t.string   "event_type",         limit: 7,                                            null: false
    t.string   "pic_url",            limit: 500,                                          null: false
    t.text     "body",               limit: 65535,                                        null: false
    t.datetime "start_time",                                                              null: false
    t.datetime "end_time",                                                                null: false
    t.integer  "user_id",            limit: 4,                                            null: false
    t.integer  "limited_people",     limit: 4,                              default: 0
    t.string   "goods_unit",         limit: 45
    t.decimal  "price",                            precision: 10, scale: 2, default: 0.0
    t.string   "pay_type",           limit: 7
    t.decimal  "goods_small_than",                 precision: 20, scale: 2, default: 0.0
    t.decimal  "goods_big_than",                   precision: 20, scale: 2, default: 0.0
    t.string   "name",               limit: 45
    t.string   "mobile",             limit: 45
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "participants_count", limit: 4,                              default: 0
    t.integer  "comments_count",     limit: 4,                              default: 0
    t.integer  "agree",              limit: 4,                              default: 0
    t.integer  "disagree",           limit: 4,                              default: 0
    t.string   "locale",             limit: 255
    t.integer  "recommend",          limit: 4
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "forums", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  add_index "forums", ["name"], name: "index_forums_on_name", unique: true, using: :btree

  create_table "groupbuys", force: :cascade do |t|
    t.string   "title",              limit: 255,                                         null: false
    t.string   "pic_url",            limit: 500,                                         null: false
    t.string   "body",               limit: 255,                                         null: false
    t.string   "locale",             limit: 45,                           default: "zh"
    t.datetime "start_time",                                                             null: false
    t.datetime "end_time",                                                               null: false
    t.integer  "user_id",            limit: 4
    t.integer  "recommend",          limit: 4,                            default: 0
    t.string   "goods_unit",         limit: 45
    t.decimal  "price",                          precision: 10, scale: 2, default: 0.0
    t.string   "pay_type",           limit: 7
    t.decimal  "goods_minimal",                  precision: 20, scale: 2, default: 0.0
    t.decimal  "goods_maximal",                  precision: 20, scale: 2, default: 0.0
    t.string   "name",               limit: 45
    t.string   "mobile",             limit: 45
    t.integer  "comments_count",     limit: 4,                            default: 0
    t.integer  "participants_count", limit: 4,                            default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groupbuys", ["user_id"], name: "index_groupbuys_on_user_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  add_index "groups", ["name"], name: "index_groups_on_name", unique: true, using: :btree

  create_table "participants", force: :cascade do |t|
    t.integer  "user_id",       limit: 4,                                           null: false
    t.string   "name",          limit: 45,                                          null: false
    t.string   "mobile",        limit: 45,                                          null: false
    t.string   "address",       limit: 255
    t.integer  "event_id",      limit: 4,                                           null: false
    t.integer  "status",        limit: 4,                             default: 0
    t.integer  "people_amount", limit: 4,                             default: 1
    t.decimal  "goods_amount",               precision: 10, scale: 2, default: 0.0
    t.string   "remark",        limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_pay",    limit: 4,                             default: 0
    t.integer  "status_ship",   limit: 4,                             default: 0
    t.integer  "groupbuy_id",   limit: 4
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name",       limit: 255,             null: false
    t.string   "url",        limit: 255
    t.integer  "rate",       limit: 4,   default: 0
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
  end

  add_index "topics", ["forum_id"], name: "index_topics_on_forum_id", using: :btree
  add_index "topics", ["user_id"], name: "index_topics_on_user_id", using: :btree

  create_table "user_instersts", force: :cascade do |t|
    t.integer  "user_id",        limit: 4, null: false
    t.string   "insterest_type", limit: 5, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",        limit: 45,                null: false
    t.string   "name",            limit: 45
    t.string   "mobile",          limit: 45
    t.string   "email",           limit: 255
    t.string   "sex",             limit: 1,   default: "0"
    t.string   "password_digest", limit: 255,               null: false
    t.string   "role",            limit: 1,   default: "0"
    t.string   "avatar",          limit: 500
    t.string   "profession",      limit: 45
    t.string   "location",        limit: 45
    t.integer  "comments_count",  limit: 4
    t.integer  "events_count",    limit: 4
    t.integer  "topics_count",    limit: 4
    t.string   "weixin_openid",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "groups_id",       limit: 4
    t.integer  "agree",           limit: 4,   default: 0
    t.integer  "disagree",        limit: 4,   default: 0
    t.integer  "group_id",        limit: 4
    t.string   "nickname",        limit: 255
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "comment_id", limit: 4
    t.integer  "event_id",   limit: 4
    t.integer  "topic_id",   limit: 4
    t.integer  "status",     limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

end
