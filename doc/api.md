# API￼

This documentation describes API version 2.

## Authentication
v2 requires authentication, which can be done in two ways:

- send `idb_api_token` as regular parameter together with a configured token
  for the target system: `?idb_api_token=abcdef`
- send `X-IDB-API-Token` as HTTP header together with a configured token for
  the target system: `X-IDB-API-Token: abcdef`

**Token parameters are missing from the examples below for the sake of brevity**

## Endpoints

Currently the following endpoints are supported:

- `machines`: Create, update and query machines.
- `cloud_providers`: Read cloud provider configuration, used to automatically fetch adapter configuration.
- `inventories`: Create, update and query inventory items.
- `software`: Similar to software search in GUI, searches for machines with specific software.

### `machines` endpoint

#### Query

Query one or multiple machines.

- Method: `GET`
- Parameters:
	- `fqdn`

##### Examples

- Single machine by fqdn: `curl -k -X GET https://idb.example.com/api/v2/machines?fqdn=test2.example.com`
- All machines: `curl -k -X GET https://idb.example.com/api/v2/machines`

#### Update / Create

Update or create one or multiple machines.

- Method: `PUT`
- Content-Type: `application/json`
- Body:
	- One machine: JSON encoded machine object. To enable creation add a field `create_machine` with value `true`.
	- Multiple machines: JSON object containing a key `machines` with an array of JSON encoded machines. To enable creation add a field `create_machine` with value `true`.

##### Examples

- Update single machine: `curl -k -g -X PUT -H "Content-Type: application/json" -d '{"fqdn": "test2.example.com", "cores": 5, "nics": [{"ip_address": {"addr": "127.0.0.1", "netmask": "255.255.255.0"}, "name": "eth0"}]}' https://idb.example.com/api/v2/machines`
- Create single machine (update if existing): `curl -k -g -X PUT -H "Content-Type: application/json" -d '{"create_machine": true, "fqdn": "test2.example.com", "cores": 5, "nics": [{"ip_address": {"addr": "127.0.0.1", "netmask": "255.255.255.0"}, "name": "eth0"}]}' https://idb.example.com/api/v2/machines`
- Update multiple machines: `curl -k -g -X PUT -H "Content-Type: application/json" -d '{"machines":[{"fqdn": "test2.example.com", "cores": 4}, {"fqdn": "test.example.com", "ram": 1024}]}' https://idb.example.com/api/v2/machines`
- Create multiple machines (update if existing): `curl -k -g -X PUT -H "Content-Type: application/json" -d '{"create_machine": true, "machines":[{"fqdn": "test2.example.com", "cores": 4}, {"fqdn": "test.example.com", "ram": 1024}]}' https://idb.example.com/api/v2/machines`

### `cloud_providers` endpoint

#### Query

Used to query cloud provider configuration.

- Method: `GET`
- Parameters: Optionally one of `id`, `name`, `owner`.

##### Examples

- Cloud provider by id: curl https://idb.example.com/api/v2/cloud_providers?id=1
- Cloud provider by name: curl https://idb.example.com/api/v2/cloud_providers?name=my_cloudprovider
- Cloud providers by owner: curl https://idb.example.com/api/v2/cloud_providers?owner=1

### `inventories` endpoint

Query or update inventory items.

#### Query

- Method: `GET`
- Parameters: Optionally one of `id`, `number`, `owner`.

##### Examples

- Query single item by id: `curl -k -X GET https://idb.example.com/api/v2/inventories?id=1`
- Query single item by inventory number: `curl -k -X GET https://idb.example.com/api/v2/inventories?number=abc123`
- Query all items with owner: `curl -k -X GET https://idb.example.com/api/v2/inventories?owner=1`

#### Create

- Method: `POST`
- Content-Type: `application/json`
- Body: JSON encoded inventory object.
- Returns: Created inventory object encoded as JSON.

##### Examples

- Create a new inventory entry: `curl -k -g -X PUT -H "Content-Type: application/json" -d '{"inventory_number": "foo", "name": "my server"}' https://idb.example.com/api/v2/inventories`

#### Update

- Method: `PUT`
- Content-Type: `application/json`
- Body: JSON encoded inventory object.
- Returns: Updated inventory object encoded as JSON.

##### Examples

- Update a inventory entry: `curl -k -g -X PUT -H "Content-Type: application/json" -d '{"id": 10, "inventory_number": "foo", "name": "your server"}' https://idb.example.com/api/v2/inventories`

### `software` endpoint

Search for machines with specific installed software. The query language used is the same as in the GUI.

#### Query

- Method: `GET`
- Parameters: `q`

##### Examples

The `q` parameters are urlencoded in this examples as space (`%20`) and `=` (`%3D`) is used in the query language.

- Search for machines with OpenVPN and nmap version 4 installed: `curl -k -X GET https://idb.example.com/api/v2/software?q=openvpn%20nmap%3D4`