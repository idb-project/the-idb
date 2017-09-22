module V3
    class Deleted < Grape::API
      helpers V3::Helpers
  
      version 'v3'
      format :json
  
      resource :deleted do
        before do
          api_enabled!
          authenticate!
          set_papertrail
          @owner = get_owner
        end
  
        resource :machines do
            route_param :fqdn, type: String, requirements: { fqdn: /[a-zA-Z0-9.-]+/ } do
                desc 'Get a deleted machine by fqdn', success: Machine::Entity
                get do
                  can_read!
                  m = Machine.owned_by(@owner).only_deleted.find_by_fqdn params[:fqdn]
                  error!('Not Found', 404) unless m
        
                  present m
                end

                desc 'Undelete a machine'
                post do
                  can_write!
                  m = Machine.owned_by(@owner).only_deleted.find_by_fqdn params[:fqdn]
                  error!('Not Found', 404) unless m
        
                  m.restore
                  redirect '/machines/'+m.fqdn
                end

                desc 'Finally delete a machine'
                delete do
                    can_write!
                    m = Machine.owned_by(@owner).only_deleted.find_by_fqdn params[:fqdn]
                    error!('Not Found', 404) unless m
                    m.really_destroy!
                  end
            end

            desc 'Return a list of deleted machines, possibly filtered', is_array: true,
                                                                 success: Machine::Entity
            get do
                can_read!

                # first get all machines
                query = Machine.owned_by(@owner).only_deleted

                # strip possible idb_api_token parameter, this isn't a key of machines
                params.delete('idb_api_token')

                # then add a where condition for each parameter of the request
                params.each do |key, value|
                # arel_table uses symbols to get a symbol from the key string
                keysym = key.to_sym
                # merge AND connects the next "where" condition, which is build using arel_table of Machine
                # (http://www.rubydoc.info/github/rails/arel/Arel/Table)
                query = query.merge(Machine.where(Machine.arel_table[keysym].eq(value)))
                end

                # test if there were any keys which are no column names.
                # otherwise the exception would be thrown when rendering.
                # return 400 for such a request.
                begin
                error!('Not Found', 404) unless query.any?
                rescue ActiveRecord::StatementInvalid
                error!('Bad Request', 400)
                end

                present query
            end
        end
      end
    end
  end
  