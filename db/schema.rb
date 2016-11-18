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

ActiveRecord::Schema.define(version: 20161028143548) do

  create_table "api_tokens", force: :cascade do |t|
    t.string  "token",       limit: 255
    t.boolean "read"
    t.boolean "write"
    t.string  "name",        limit: 255
    t.string  "description", limit: 255
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "description",             limit: 255
    t.string   "attachment",              limit: 255
    t.integer  "inventory_id",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 4
    t.datetime "attachment_updated_at"
    t.integer  "owner_id",                limit: 4
    t.integer  "machine_id",              limit: 4
  end

  create_table "cloud_providers", force: :cascade do |t|
    t.integer "owner_id",    limit: 4
    t.string  "name",        limit: 255
    t.string  "description", limit: 255
    t.text    "config",      limit: 4294967295
  end

  create_table "inventories", force: :cascade do |t|
    t.string   "inventory_number", limit: 255
    t.string   "name",             limit: 255
    t.string   "serial",           limit: 255
    t.string   "part_number",      limit: 255
    t.string   "purchase_date",    limit: 255
    t.string   "warranty_end",     limit: 255
    t.string   "seller",           limit: 255
    t.integer  "status",           limit: 4,     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",          limit: 4
    t.integer  "machine_id",       limit: 4
    t.datetime "deleted_at"
    t.text     "comment",          limit: 65535
    t.string   "place",            limit: 255
    t.string   "category",         limit: 255
    t.integer  "owner_id",         limit: 4
    t.integer  "location_id",      limit: 4
    t.string   "install_date",     limit: 255
  end

  create_table "ip_addresses", force: :cascade do |t|
    t.string   "addr",       limit: 255
    t.string   "netmask",    limit: 255
    t.string   "family",     limit: 255
    t.integer  "nic_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "addr_v6",    limit: 255
    t.string   "netmask_v6", limit: 255
  end

  add_index "ip_addresses", ["addr", "nic_id"], name: "index_ip_addresses_on_addr_and_nic_id", unique: true, using: :btree
  add_index "ip_addresses", ["deleted_at"], name: "index_ip_addresses_on_deleted_at", using: :btree
  add_index "ip_addresses", ["nic_id"], name: "index_ip_addresses_on_nic_id", using: :btree

  create_table "location_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   limit: 4, null: false
    t.integer "descendant_id", limit: 4, null: false
    t.integer "generations",   limit: 4, null: false
  end

  create_table "location_levels", force: :cascade do |t|
    t.string  "name",        limit: 255
    t.string  "description", limit: 255
    t.integer "level",       limit: 4
  end

  create_table "locations", force: :cascade do |t|
    t.string  "name",              limit: 255
    t.string  "description",       limit: 255
    t.integer "level",             limit: 4
    t.integer "location_id",       limit: 4
    t.integer "location_level_id", limit: 4
  end

  create_table "machine_aliases", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "machine_id", limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "machine_aliases", ["machine_id"], name: "index_machine_aliases_on_machine_id", using: :btree
  add_index "machine_aliases", ["name"], name: "index_machine_aliases_on_name", unique: true, using: :btree

  create_table "machines", force: :cascade do |t|
    t.string   "fqdn",                                     limit: 255,                        null: false
    t.string   "os",                                       limit: 255
    t.string   "arch",                                     limit: 255
    t.integer  "ram",                                      limit: 4
    t.integer  "cores",                                    limit: 4
    t.string   "vmhost",                                   limit: 255
    t.datetime "serviced_at"
    t.text     "description",                              limit: 4294967295
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "os_release",                               limit: 255
    t.integer  "uptime",                                   limit: 4
    t.integer  "device_type_id",                           limit: 4
    t.string   "serialnumber",                             limit: 255
    t.integer  "owner_id",                                 limit: 4
    t.integer  "backup_type",                              limit: 4,          default: 0
    t.boolean  "auto_update",                                                 default: false
    t.string   "switch_url",                               limit: 255
    t.string   "mrtg_url",                                 limit: 255
    t.text     "config_instructions",                      limit: 65535
    t.text     "sw_characteristics",                       limit: 65535
    t.text     "business_purpose",                         limit: 65535
    t.string   "business_criticality",                     limit: 255
    t.string   "business_notification",                    limit: 255
    t.boolean  "unattended_upgrades",                                         default: false
    t.text     "unattended_upgrades_blacklisted_packages", limit: 65535
    t.boolean  "unattended_upgrades_reboot",                                  default: false
    t.string   "unattended_upgrades_time",                 limit: 255
    t.text     "unattended_upgrades_repos",                limit: 65535
    t.integer  "pending_updates",                          limit: 4
    t.integer  "pending_security_updates",                 limit: 4
    t.integer  "pending_updates_sum",                      limit: 4
    t.integer  "diskspace",                                limit: 8
    t.text     "pending_updates_package_names",            limit: 65535
    t.text     "severity_class",                           limit: 65535
    t.string   "ucs_role",                                 limit: 255
    t.integer  "backup_brand",                             limit: 4,          default: 0
    t.string   "backup_last_full_run",                     limit: 255
    t.string   "backup_last_inc_run",                      limit: 255
    t.string   "backup_last_diff_run",                     limit: 255
    t.integer  "power_feed_a",                             limit: 4
    t.integer  "power_feed_b",                             limit: 4
    t.text     "raw_data_api",                             limit: 4294967295
    t.text     "raw_data_puppetdb",                        limit: 4294967295
    t.integer  "backup_last_full_size",                    limit: 8
    t.integer  "backup_last_inc_size",                     limit: 8
    t.integer  "backup_last_diff_size",                    limit: 8
    t.integer  "needs_reboot",                             limit: 4
  end

  add_index "machines", ["deleted_at"], name: "index_machines_on_deleted_at", using: :btree
  add_index "machines", ["fqdn"], name: "index_machines_on_fqdn", unique: true, using: :btree

  create_table "maintenance_records", force: :cascade do |t|
    t.string   "fqdn",       limit: 255
    t.integer  "machine_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.binary   "logfile",    limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "maintenance_records", ["deleted_at"], name: "index_maintenance_records_on_deleted_at", using: :btree
  add_index "maintenance_records", ["fqdn", "created_at"], name: "index_maintenance_records_on_fqdn_and_created_at", unique: true, using: :btree
  add_index "maintenance_records", ["fqdn"], name: "index_maintenance_records_on_fqdn", using: :btree
  add_index "maintenance_records", ["machine_id"], name: "index_maintenance_records_on_machine_id", using: :btree
  add_index "maintenance_records", ["user_id"], name: "index_maintenance_records_on_user_id", using: :btree

  create_table "networks", force: :cascade do |t|
    t.string   "name",        limit: 255,        null: false
    t.string   "address",     limit: 255,        null: false
    t.text     "description", limit: 4294967295
    t.integer  "owner_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "preferences", limit: 4294967295
  end

  add_index "networks", ["address"], name: "index_networks_on_address", unique: true, using: :btree
  add_index "networks", ["name"], name: "index_networks_on_name", unique: true, using: :btree
  add_index "networks", ["owner_id"], name: "index_networks_on_owner_id", using: :btree

  create_table "nics", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "mac",        limit: 255
    t.integer  "machine_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "nics", ["deleted_at"], name: "index_nics_on_deleted_at", using: :btree
  add_index "nics", ["mac"], name: "index_nics_on_mac", using: :btree
  add_index "nics", ["machine_id"], name: "index_nics_on_machine_id", using: :btree
  add_index "nics", ["name", "machine_id"], name: "index_nics_on_name_and_machine_id", unique: true, using: :btree

  create_table "operating_systems", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "family",         limit: 255
    t.string   "releaseversion", limit: 255
    t.string   "majorversion",   limit: 255
    t.string   "minorversion",   limit: 255
    t.boolean  "eol",                          default: true
    t.text     "severity_class", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "owners", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname",    limit: 255
    t.string   "customer_id", limit: 255
    t.datetime "deleted_at"
    t.text     "data",        limit: 4294967295
    t.string   "wiki_url",    limit: 255
    t.string   "repo_url",    limit: 255
  end

  add_index "owners", ["customer_id"], name: "index_owners_on_customer_id", using: :btree
  add_index "owners", ["deleted_at"], name: "index_owners_on_deleted_at", using: :btree
  add_index "owners", ["nickname"], name: "index_owners_on_nickname", unique: true, using: :btree

  create_table "switch_ports", force: :cascade do |t|
    t.integer  "number",     limit: 4,   null: false
    t.string   "identifier", limit: 255
    t.integer  "nic_id",     limit: 4,   null: false
    t.integer  "switch_id",  limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "switch_ports", ["nic_id"], name: "index_switch_ports_on_nic_id", using: :btree
  add_index "switch_ports", ["number", "switch_id"], name: "index_switch_ports_on_number_and_switch_id", unique: true, using: :btree
  add_index "switch_ports", ["number"], name: "index_switch_ports_on_number", using: :btree
  add_index "switch_ports", ["switch_id"], name: "index_switch_ports_on_switch_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",           limit: 255
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "password_digest", limit: 255
    t.string   "carLicence",      limit: 255
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255,        null: false
    t.integer  "item_id",        limit: 4,          null: false
    t.string   "event",          limit: 255,        null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object",         limit: 4294967295
    t.text     "object_changes", limit: 4294967295
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
