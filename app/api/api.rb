module MachineHelpers
 def process_machine_update(p)
    create_machine = p["create_machine"]

    payload = p.clone
    token = p["idb_api_token"] ? p["idb_api_token"] : request.headers["X-Idb-Api-Token"] ? request.headers["X-Idb-Api-Token"] : nil
    token_name = token.nil? ? "no token" : token
    # do not store the token itself if provided, that is potentially classified to users
    payload.delete("idb_api_token")
    payload.delete("create_machine")
    payload.delete("fqdn")

    p["raw_data_api"] = {token_name => payload}.to_json

    PaperTrail.whodunnit = token_name

    # strip all params that are not attributes of a machine
    # and prepare some params
    p = p.reject { |k| !Machine.attribute_method?(k) }
    p_nics = Hash.new
    p_nics[:nics] = p.delete("nics")

    p_aliases = Hash.new
    p_aliases[:aliases] = p.delete("aliases")

    # backup handling
    is_backed_up = false
    if (
      (p["backup_brand"] && p["backup_brand"].to_i > 0) ||
      !p["backup_last_full_run"].blank? ||
      !p["backup_last_inc_run"].blank? ||
      !p["backup_last_diff_run"].blank? ||
      !p["backup_last_full_size"].blank? ||
      !p["backup_last_inc_size"].blank? ||
      !p["backup_last_diff_size"].blank?
      )
      is_backed_up = true
    end

    m = Machine.find_by_fqdn(p["fqdn"])
    if m.nil?
      if (create_machine == "true" || create_machine == true)
        # without an owner use the first existing owner
        if p["owner_id"].nil?
          if Owner.first.nil?
            Rails.logger.error "Owner is missing. Please create at least one owner."
          end

          p["owner_id"] = Owner.first.id
        end
        p["owner_id"] = Owner.first.id unless p["owner_id"]

        m = Machine.new(p)
        m.backup_type = 1 if is_backed_up
        m.update_details_by_api(p_nics, EditableMachineForm.new(m))
        m.update_details_by_api(p_aliases, EditableMachineForm.new(m))
        m.save!
        VersionChangeWorker.perform_async(m.versions.last.id, "API")
      else
        m = nil
      end
    else
      unless m.raw_data_api.nil?
        result = JSON.parse(m.raw_data_api).merge!({token_name => payload})
        p["raw_data_api"] = result.to_json
      end
      m.update_attributes(p)
      m.backup_type = 1 if is_backed_up
      m.update_details_by_api(p_nics, EditableMachineForm.new(m))
      m.update_details_by_api(p_aliases, EditableMachineForm.new(m))
    end
    m
  end
end

class API < Grape::API
  error_formatter :json, ErrorFormatter
  mount V1::API
  mount V2::API
end
