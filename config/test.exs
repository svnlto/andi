use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :andi, AndiWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :andi,
  ldap_user: [cn: "admin"],
  ldap_pass: "admin",
  ldap_env_ou: "test"

config :paddle, Paddle, base: "dc=foo,dc=bar"
