Rack::Utils.default_query_parser = Rack::QueryParser.make_default(
  100, # параметр, отвечающий за лимит поля
  params_limit: 7_000 # увеличиваем лимит до 10000 (или больше)
)
