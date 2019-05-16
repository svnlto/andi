use Mix.Config

config :smart_city_registry,
  redis: [
    host: System.get_env("REDIS_HOST")
  ]
