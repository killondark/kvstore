defmodule KVstore.Storage do
  import Plug.Conn
  require Logger

  def init(options), do: options

  def call(conn, _opts), do: conn

  def index(conn) do
    KVstore.Utils.open_table()
    kvlists = :dets.match(:kvstore, {:"$1", :"$2", :"$3"})
    KVstore.Utils.close_table()
    send_resp(conn, 200, "Listing kvstore records\n#{Kernel.inspect(kvlists)}")
  end

  def show(conn) do
    KVstore.Utils.open_table()
    kvlist = :dets.match_object(:kvstore, {conn.params["key"], :"$2", :"$3"})
    KVstore.Utils.close_table()
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
    conn =
      conn
      |> put_req_header("content-type", "application/x-www-form-urlencoded")
      |> KVstore.Utils.parse()
    Logger.info("Create record #{Kernel.inspect(conn.params)}")
    {:ok, table} = KVstore.Utils.open_table()
    :dets.insert_new(table, {conn.params["key"],
                             conn.params["value"],
                             conn.params["ttl"]})
    KVstore.Utils.close_table()
    KVstore.Utils.run_async_task(conn.params["key"], conn.params["ttl"])
    send_resp(conn, 200, "Saved in DETS")
  end

  def update(conn) do
    conn =
      conn
      |> put_req_header("content-type", "application/x-www-form-urlencoded")
      |> KVstore.Utils.parse()
    {:ok, table} = KVstore.Utils.open_table()
    :dets.insert_new(table, {conn.params["new_key"],
                             conn.params["value"],
                             conn.params["ttl"]})
    :dets.delete(table, conn.params["key"])
    KVstore.Utils.close_table()
    KVstore.Utils.run_async_task(conn.params["new_key"], conn.params["ttl"])
    send_resp(conn, 200, "Updated in DETS")
  end

  def destroy(conn) do
    {:ok, table} = KVstore.Utils.open_table()
    :dets.delete(table, conn.params["key"])
    KVstore.Utils.close_table()
    send_resp(conn, 200, "Removed record with #{conn.params["key"]}")
  end
end
