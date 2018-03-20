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

ActiveRecord::Schema.define(version: 20180320100202) do

  create_table "api_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "token"
    t.boolean "read"
    t.boolean "write"
    t.string  "name"
    t.string  "description"
    t.integer "owner_id"
  end

  create_table "attachments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "description"
    t.string   "attachment"
    t.integer  "inventory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "owner_id"
    t.integer  "machine_id"
    t.string   "attachment_fingerprint"
    t.integer  "maintenance_record_id"
  end

  create_table "cloud_providers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "owner_id"
    t.string  "name"
    t.string  "description"
    t.text    "config",      limit: 4294967295
    t.string  "apidocs"
  end

  create_table "inventories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "inventory_number"
    t.string   "name"
    t.string   "serial"
    t.string   "part_number"
    t.string   "purchase_date"
    t.string   "warranty_end"
    t.string   "seller"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "machine_id"
    t.datetime "deleted_at"
    t.text     "comment",             limit: 65535
    t.string   "place"
    t.string   "category"
    t.integer  "owner_id"
    t.integer  "location_id"
    t.string   "install_date"
    t.integer  "inventory_status_id"
  end

  create_table "inventory_statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name"
    t.boolean "inactive", default: false
  end

  create_table "ip_addresses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "addr"
    t.string   "netmask"
    t.string   "family"
    t.integer  "nic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "addr_v6"
    t.string   "netmask_v6"
    t.index ["addr", "nic_id"], name: "index_ip_addresses_on_addr_and_nic_id", unique: true, using: :btree
    t.index ["deleted_at"], name: "index_ip_addresses_on_deleted_at", using: :btree
    t.index ["nic_id"], name: "index_ip_addresses_on_nic_id", using: :btree
  end

  create_table "location_hierarchies", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  create_table "location_levels", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name"
    t.string  "description"
    t.integer "level"
    t.integer "owner_id"
  end

  create_table "locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name"
    t.string  "description"
    t.integer "level"
    t.integer "location_id"
    t.integer "location_level_id"
    t.integer "owner_id"
  end

  create_table "machine_aliases", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "machine_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["machine_id"], name: "index_machine_aliases_on_machine_id", using: :btree
    t.index ["name"], name: "index_machine_aliases_on_name", unique: true, using: :btree
  end

  create_table "machines", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "fqdn",                                                                        null: false
    t.string   "os"
    t.string   "arch"
    t.integer  "ram"
    t.integer  "cores"
    t.string   "vmhost"
    t.datetime "serviced_at"
    t.text     "description",                              limit: 4294967295
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "os_release"
    t.integer  "uptime"
    t.string   "serialnumber"
    t.integer  "owner_id"
    t.integer  "backup_type",                                                 default: 0
    t.boolean  "auto_update",                                                 default: false
    t.string   "switch_url"
    t.string   "mrtg_url"
    t.text     "config_instructions",                      limit: 65535
    t.text     "sw_characteristics",                       limit: 65535
    t.text     "business_purpose",                         limit: 65535
    t.string   "business_criticality"
    t.string   "business_notification"
    t.boolean  "unattended_upgrades",                                         default: false
    t.text     "unattended_upgrades_blacklisted_packages", limit: 65535
    t.boolean  "unattended_upgrades_reboot",                                  default: false
    t.string   "unattended_upgrades_time"
    t.text     "unattended_upgrades_repos",                limit: 65535
    t.integer  "pending_updates"
    t.integer  "pending_security_updates"
    t.integer  "pending_updates_sum"
    t.bigint   "diskspace"
    t.text     "pending_updates_package_names",            limit: 65535
    t.text     "severity_class",                           limit: 65535
    t.string   "ucs_role"
    t.integer  "backup_brand",                                                default: 0
    t.string   "backup_last_full_run"
    t.string   "backup_last_inc_run"
    t.string   "backup_last_diff_run"
    t.integer  "power_feed_a"
    t.integer  "power_feed_b"
    t.text     "raw_data_api",                             limit: 4294967295
    t.text     "raw_data_puppetdb",                        limit: 4294967295
    t.bigint   "backup_last_full_size"
    t.bigint   "backup_last_inc_size"
    t.bigint   "backup_last_diff_size"
    t.integer  "needs_reboot"
    t.json     "software"
    t.string   "type"
    t.integer  "announcement_deadline"
    t.index ["deleted_at"], name: "index_machines_on_deleted_at", using: :btree
    t.index ["fqdn"], name: "index_machines_on_fqdn", unique: true, using: :btree
  end

  create_table "machines_maintenance_tickets", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "maintenance_ticket_id", null: false
    t.integer "machine_id",            null: false
  end

  create_table "maintenance_announcements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "begin_date"
    t.text     "reason",                  limit: 65535
    t.text     "impact",                  limit: 65535
    t.integer  "maintenance_template_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.datetime "end_date"
    t.index ["maintenance_template_id"], name: "index_maintenance_announcements_on_maintenance_template_id", using: :btree
  end

  create_table "maintenance_records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "fqdn"
    t.integer  "machine_id"
    t.integer  "user_id"
    t.binary   "logfile",    limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_maintenance_records_on_deleted_at", using: :btree
    t.index ["fqdn", "created_at"], name: "index_maintenance_records_on_fqdn_and_created_at", unique: true, using: :btree
    t.index ["fqdn"], name: "index_maintenance_records_on_fqdn", using: :btree
    t.index ["machine_id"], name: "index_maintenance_records_on_machine_id", using: :btree
    t.index ["user_id"], name: "index_maintenance_records_on_user_id", using: :btree
  end

  create_table "maintenance_templates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "body",       limit: 65535
    t.string   "name"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "subject"
  end

  create_table "maintenance_tickets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "ticket_id"
    t.datetime "date"
    t.integer  "maintenance_announcement_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["maintenance_announcement_id"], name: "index_maintenance_tickets_on_maintenance_announcement_id", using: :btree
  end

  create_table "networks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                           null: false
    t.string   "address",                        null: false
    t.text     "description", limit: 4294967295
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "preferences", limit: 4294967295
    t.index ["address"], name: "index_networks_on_address", unique: true, using: :btree
    t.index ["name"], name: "index_networks_on_name", unique: true, using: :btree
    t.index ["owner_id"], name: "index_networks_on_owner_id", using: :btree
  end

  create_table "nics", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "mac"
    t.integer  "machine_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_nics_on_deleted_at", using: :btree
    t.index ["mac"], name: "index_nics_on_mac", using: :btree
    t.index ["machine_id"], name: "index_nics_on_machine_id", using: :btree
    t.index ["name", "machine_id"], name: "index_nics_on_name_and_machine_id", unique: true, using: :btree
  end

  create_table "operating_systems", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "family"
    t.string   "releaseversion"
    t.string   "majorversion"
    t.string   "minorversion"
    t.boolean  "eol",                          default: true
    t.text     "severity_class", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "owners", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname"
    t.string   "customer_id"
    t.datetime "deleted_at"
    t.text     "data",        limit: 4294967295
    t.string   "wiki_url"
    t.string   "repo_url"
    t.index ["customer_id"], name: "index_owners_on_customer_id", using: :btree
    t.index ["deleted_at"], name: "index_owners_on_deleted_at", using: :btree
    t.index ["nickname"], name: "index_owners_on_nickname", unique: true, using: :btree
  end

  create_table "owners_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "owner_id"
    t.integer "user_id"
    t.index ["owner_id"], name: "index_owners_users_on_owner_id", using: :btree
    t.index ["user_id"], name: "index_owners_users_on_user_id", using: :btree
  end

  create_table "switch_ports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "number",     null: false
    t.string   "identifier"
    t.integer  "nic_id",     null: false
    t.integer  "switch_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["nic_id"], name: "index_switch_ports_on_nic_id", using: :btree
    t.index ["number", "switch_id"], name: "index_switch_ports_on_number_and_switch_id", unique: true, using: :btree
    t.index ["number"], name: "index_switch_ports_on_number", using: :btree
    t.index ["switch_id"], name: "index_switch_ports_on_switch_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "login"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "password_digest"
    t.string   "carLicence"
    t.boolean  "admin"
    t.index ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
    t.index ["login"], name: "index_users_on_login", unique: true, using: :btree
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "item_type",                         null: false
    t.integer  "item_id",                           null: false
    t.string   "event",                             null: false
    t.string   "whodunnit"
    t.text     "object",         limit: 4294967295
    t.text     "object_changes", limit: 4294967295
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  add_foreign_key "maintenance_announcements", "maintenance_templates"
  add_foreign_key "maintenance_tickets", "maintenance_announcements"
end
