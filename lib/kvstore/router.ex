defmodule KVstore.Router do
  use Plug.Router
  
  alias KVstore.Storage
  alias KVstore.Utils

  plug(:match)
  plug(:dispatch)

  get("/favicon.ico", do: send_resp(conn, 200, 'Favicon spike'))

  get "/index" do
    kvlists = Storage.index(conn)
    send_resp(conn, 200, "Listing kvstore records\n#{Kernel.inspect(kvlists)}")
  end

  get "/new" do
    Storage.new(conn)
    send_resp(conn, 200, "You can make request to create action with params")
  end

  get "/show/:key" do 
    kvlist = Storage.show(conn)
    send_resp(conn, 200, "Show kvstore record\n#{Kernel.inspect(kvlist)}")
  end

  put "/update/:old_key" do
    conn = Utils.validate(conn)
    case Integer.parse(conn.params["ttl"]) do
      :error -> send_resp(conn, 400, "Invalid ttl value")
      _ ->
        Storage.update(conn)
        send_resp(conn, 200, "Updated in DETS")
    end
  end

  post "/create" do
    conn = Utils.validate(conn)
    case Integer.parse(conn.params["ttl"]) do
      :error -> send_resp(conn, 400, "Invalid ttl value")
      _ ->
        Storage.create(conn)
        send_resp(conn, 200, "Saved in DETS")
    end
  end

  delete "/destroy/:key" do
    Storage.destroy(conn)
    send_resp(conn, 200, "Removed record with #{conn.params["key"]}")
  end

  get("/", do: send_resp(conn, 200, "Welcome to KVstore"))
  match(_, do: send_resp(conn, 404, "Oops!"))
end
