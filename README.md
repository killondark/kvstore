# Kvstore

Usage:

1. Show all records in kvstore: `curl http://localhost:8080/index`
2. Create record: `curl --request POST http://localhost:8080/create --data "key=key&value=value&ttl=1000"`
3. Show record: `curl http://localhost:8080/show/key`
4. Update record: `curl --request PUT http://localhost:8080/update/key --data "key=updated_key&value=updated_value&ttl=1000"`
5. Destroy record: `curl --request DELETE http://localhost:8080/destroy/updated_key`
