class TransformRawApiData < ActiveRecord::Migration[5.0]
  def change
    tokens = ApiToken.all.map(&:name)
    Machine.all.each do |m|
      if m.raw_data_api
        token_found = false
        json = JSON.parse(m.raw_data_api)
        tokens.each do |token|
          token_found = true if json.keys.include?(token)
        end
        if !token_found && ApiToken.count > 0
          result = {ApiToken.first.name => JSON.parse(m.raw_data_api)}.to_json
          m.raw_data_api = result
          m.save!
        end
      end
    end
  end
end
