# API￼

## v2￼

### Authentication
v2 requires authentication, which can be done in two ways:

- send `idb_api_token` as regular parameter together with a configured token
  for the target system: `?idb_api_token=abcdef`
- send `X-IDB-API-Token` as HTTP header together with a configured token for
  the target system: `X-IDB-API-Token: abcdef`

**Token parameters are missing from the examples below for the sake of brevity**

### Endpoints

Currently the following endpoints are supported:

- `machines`: Create, update and query machines.
- `cloud_providers`: Read cloud provider configuration, used to automatically fetch
  adapter configuration.
- `cloud_providers/$NAME`: Read cloud provider configuration by name.


#### `machines` endpoint

<dl>
	<dt>Query</dt>
	<dd>
		<dl>
		<dt>Description</dt>	<dd>Used to query one or multiple machines.</dd>
		<dt>Method</dt>	<dd>GET</dd>
		<dt>Parameters</dt>	<dd>fqdn (optional to query a single machine)</dd>
		<dt>Examples</dt>
			<dd>
				<dl>
					<dt>Single machine:</dt><dd><code>curl -k -X GET https://idb.example.com/api/v2/machines?fqdn=test2.example.com</code></dd>
					<dt>All machines:</dt><dd><code>curl -k -X GET https://idb.example.com/api/v2/machines</code></dd>
				</dl>
			</dd>
		</dl>
	</dd>
	<dt>Update / Create</dt>
	<dd>
		<dl>
		<dt>Description</dt>	<dd>Update or create one or multiple machines.</dd>
		<dt>Method</dt>	<dd><code>PUT</code></dd>
		<dt>Content-Type</dt>	<dd>application/json</dd>
		<dt>Body</dt><dd>
										<dl>
											<dt>One machine</dt><dd>JSON encoded machine object. To enable creation add a field <code>create_machine</code> with value <code>true</code>.</dd>
											<dt>Multiple machines</dt><dd>JSON object with <code>machines</code> field containing an array of JSON encoded machines. To enable creation add a field <code>create_machine</code> with value <code>true</code>.</dd>
										</dl>
									</dd>
		<dt>Examples</dt>
			<dd>
				<dl>
					<dt>Update single machine</dt>
					<dd>
						<code>curl -k -g -X PUT -H "Content-Type: application/json" -d '{"fqdn": "test2.example.com", "cores": 5, "nics": [{"ip_address": {"addr": "127.0.0.1", "netmask": "255.255.255.0"}, "name": "eth0"}]}' https://idb.example.com/api/v2/machines</code>
					</dd>
					<dt>Create single machine (update if existing)</dt>
					<dd>
						<code>curl -k -g -X PUT -H "Content-Type: application/json" -d '{"create_machine": true, "fqdn": "test2.example.com", "cores": 5, "nics": [{"ip_address": {"addr": "127.0.0.1", "netmask": "255.255.255.0"}, "name": "eth0"}]}' https://idb.example.com/api/v2/machines</code>
					</dd>
					<dt>Update multiple machines</dt>
					<dd>
						<code>curl -k -g -X PUT -H "Content-Type: application/json" -d '{"machines":[{"fqdn": "test2.example.com", "cores": 4}, {"fqdn": "test.example.com", "ram": 1024}]}' https://idb.example.com/api/v2/machines</code>
					</dd>
					<dt>Create multiple machines (update if existing)</dt>
					<dd>
						<code>curl -k -g -X PUT -H "Content-Type: application/json" -d '{"create_machine": true, "machines":[{"fqdn": "test2.example.com", "cores": 4}, {"fqdn": "test.example.com", "ram": 1024}]}' https://idb.example.com/api/v2/machines</code>
					</dd>
				</dl>
			</dd>
		</dl>
	</dd>
</dl>

#### `cloud_providers` endpoint

<dl>
	<dt>Query</dt>
	<dd>
		<dl>
			<dt>Description</dt><dd>Used to query cloud provider configuration</dd>
			<dt>Method</dt><dd><code>GET</code></dd>
			<dt>Parameters</dt><dd><code>owner</code> (optional, only return configurations of this owner)</dd>
			<dt>Examples</dt>
			<dd><code>curl https://idb.example.com/api/v2/cloud_providers</code></dd>
		</dl>
	</dd>
</dl>

#### `cloud_providers/$NAME` endpoint

<dl>
	<dt>Query</dt>
	<dd>
		<dl>
			<dt>Description</dt><dd>Querys the cloud provider configuration having this name.</dd>
			<dt>Method</dt><dd><code>GET</code></dd>
			<dt>Examples</dt>
			<dd><code>curl https://idb.example.com/api/v2/cloud_providers/test</code></dd>
		</dl>
	</dd>
</dl>
