use Mix.Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
# config :andi, AndiWeb.Endpoint,
#   http: [:inet6, port: System.get_env("PORT") || 4000],
#   # url: [host: "example.com", port: 80],
#   # cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

config :andi, AndiWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  server: true,
  root: ".",
  version: Application.spec(:andi, :vsn)


config :kaffe,
  producer: [
    endpoints: [kafka: 9092],
    topics: ["dataset-registry"]
  ]