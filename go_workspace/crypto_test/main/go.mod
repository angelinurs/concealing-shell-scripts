module crypto_test/main

go 1.21.4

replace crypto_test/handler_crypto => ../handler_crypto

replace crypto_test/handler_db => ../handler_db

replace crypto_test/handler_file => ../handler_file

replace crypto_test/handler_yaml => ../handler_yaml

replace crypto_test/handler_argument => ../handler_argument

require (
	crypto_test/handler_argument v0.0.0-00010101000000-000000000000
	crypto_test/handler_crypto v0.0.0-00010101000000-000000000000
	crypto_test/handler_db v0.0.0-00010101000000-000000000000
	crypto_test/handler_file v0.0.0-00010101000000-000000000000
	crypto_test/handler_yaml v0.0.0-00010101000000-000000000000
)

require (
	github.com/lib/pq v1.10.9 // indirect
	golang.org/x/crypto v0.24.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)
