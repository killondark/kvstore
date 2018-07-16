defmodule KVstore.Storage do
  import Plug.Conn
  require Logger

  alias KVstore.Utils

  def init(options), do: options

  def call(conn, _opts), do: conn

  def index(conn) do
    kvlists = :dets.match(Utils.kvstore_name(), {:"$1", :"$2", :"$3"})
    send_resp(conn, 200, "Listing kvstore records\n#{Kernel.inspect(kvlists)}")
  end

  def show(conn) do
    kvlist = :dets.match_object(Utils.kvstore_name(), {conn.params["key"], :"$2", :"$3"})
    send_resp(conn, 200, "Show kvstore record\n#{Kernel.inspect(kvlist)}")
  end

  def new(conn) do
    # Use when CRUD in a web interface
    # conn
    # |> put_resp_header("content-type", "text/html; charset=utf-8")
    # |> send_file(200, "lib/web/new.html")
    send_resp(conn, 200, "You can make request to create action with params")
  end

  def create(conn) do
    conn = parse(conn)
    case Integer.parse(conn.params["ttl"]) do
      :error -> send_resp(conn, 200, "Invalid ttl value")
      _ ->
        :dets.insert_new(Utils.kvstore_name(), {conn.params["key"],
                          conn.params["value"],
                          conn.params["ttl"]})
        Logger.info("Create record #{Kernel.inspect(conn.params)}")
        KVstore.Utils.run_async_task(conn.params["key"], conn.params["ttl"])
        send_resp(conn, 200, "Saved in DETS")
    end
  end

  def update(conn) do
    conn = parse(conn)
    case Integer.parse(conn.params["ttl"]) do
      :error -> send_resp(conn, 200, "Invalid ttl value")
      _ ->
        :dets.delete(Utils.kvstore_name(), conn.params["old_key"])
        :dets.insert_new(Utils.kvstore_name(), {conn.params["key"],
                          conn.params["value"],
                          conn.params["ttl"]})
        KVstore.Utils.run_async_task(conn.params["key"], conn.params["ttl"])
        send_resp(conn, 200, "Updated in DETS")
    end
  end

  def destroy(conn) do
    :dets.delete(Utils.kvstore_name(), conn.params["key"])
    send_resp(conn, 200, "Removed record with #{conn.params["key"]}")
  end

  defp parse(conn) do
    conn
    |> put_req_header("content-type", "application/x-www-form-urlencoded")
    |> KVstore.Utils.parse()
  end
end
