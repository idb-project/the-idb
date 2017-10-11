def api_get(action:, token:, params: {}, version: "2")
  params.merge!({"idb_api_token": token.token })
  get "/api/v#{version}/#{action}", params: params
  JSON.parse(response.body) rescue {}
end

def api_get_auth_header(action: , token: , params: {}, version: "2")
  get "/api/v#{version}/#{action}", params: params, headers: {'X-IDB-API-Token': token.token }
  JSON.parse(response.body) rescue {}
end

def api_get_unauthorized(action: , params: {}, version: "2")
  get "/api/v#{version}/#{action}", params: params
  JSON.parse(response.body) rescue {}
end

def api_post(action: , token: , params: {}, version: "2")
  #params.merge!({"idb_api_token": token.token })
  post "/api/v#{version}/#{action}", params: params, headers: {'X-IDB-API-Token': token.token }
  JSON.parse(response.body) rescue {}
end

def api_post_json(action: , token: , payload: , version: "2")
  #payload.merge!({"idb_api_token": token.token })
  post "/api/v#{version}/#{action}", params: payload, as: :json, headers: {'X-IDB-API-Token': token.token }
  JSON.parse(response.body) rescue {}
end

def api_delete(action: , token: , params: {}, version: "2")
  #params.merge!({"idb_api_token": token.token })
  delete "/api/v#{version}/#{action}", params: params, headers: {'X-IDB-API-Token': token.token }
  JSON.parse(response.body) rescue {}
end

def api_put(action: , token: , params: {}, version: "2")
  #params.merge!({"idb_api_token": token.token })
  put "/api/v#{version}/#{action}", params: params, headers: {'X-IDB-API-Token': token.token }
  JSON.parse(response.body) rescue {}
end

def api_put_json(action: , token: , payload: , version: "2")
  #payload.merge!({"idb_api_token": token.token })
  put "/api/v#{version}/#{action}", params: payload, as: :json, headers: {'X-IDB-API-Token': token.token }
  JSON.parse(response.body) rescue {}
end
