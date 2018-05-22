defmodule KVstore.Storage do
  import Plug.Conn
  require Logger

  def init(options), do: options

  def call(conn, _opts), do: conn

  def new(conn) do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_file(200, "lib/web/new.html")
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
end
