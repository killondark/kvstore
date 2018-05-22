defmodule KVstore.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get("/favicon.ico", do: send_resp(conn, 200, 'Favicon spike'))
  get("/new", do: KVstore.Storage.new(conn))
  post("/create", do: KVstore.Storage.create(conn))

  get("/", do: send_resp(conn, 200, "Welcome to KVstore"))
  match(_, do: send_resp(conn, 404, "Oops!"))
end
