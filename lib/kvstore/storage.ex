defmodule KVstore.Storage do
  import Plug.Conn
  require Logger

  alias KVstore.Utils

  def init(options), do: options

  def call(conn, _opts), do: conn

  def index(_conn) do
    match_params(kvstore_name(), {:"$1", :"$2", :"$3"})
  end

  def show(conn) do
    :dets.match_object(kvstore_name(), {conn.params["key"], :"$2", :"$3"})
  end

  def new(_conn) do
    # Use when CRUD in a web interface
    # conn
    # |> put_resp_header("content-type", "text/html; charset=utf-8")
    # |> send_file(200, "lib/web/new.html")
  end

  def create(conn) do
    :dets.insert_new(kvstore_name(), {conn.params["key"],
                      conn.params["value"],
                      conn.params["ttl"]})
    Logger.info("Create record #{Kernel.inspect(conn.params)}")
    Utils.run_async_task(conn.params["key"], conn.params["ttl"])
  end

  def update(conn) do
    delete_key(kvstore_name(), conn.params["old_key"])
    :dets.insert_new(kvstore_name(), {conn.params["key"],
                      conn.params["value"],
                      conn.params["ttl"]})
    Utils.run_async_task(conn.params["key"], conn.params["ttl"])
  end

  def destroy(conn) do
    delete_key(kvstore_name(), conn.params["key"])
  end

  def delete_key(kvstore_name, key) do
    :dets.delete(kvstore_name, key)
  end

  def open_table do
    :dets.open_file(kvstore_name(), [type: :set])
  end

  def kvstore_name do
    Application.fetch_env!(:kvstore, :dets)
  end

  def match_params(kvstore_name, params) do
    :dets.match(kvstore_name, params)
  end
end
