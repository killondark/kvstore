defmodule KVstore.Utils do
  import Plug.Conn
  require Logger

  alias KVstore.Storage

  def parse(conn, opts \\ []) do
    opts = Keyword.put_new(opts, :parsers, [Plug.Parsers.URLENCODED, Plug.Parsers.MULTIPART])
    Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  end

  def validate(conn) do
    conn
    |> put_req_header("content-type", "application/x-www-form-urlencoded")
    |> parse()
  end

  def remove(key, ttl) do
    {ttl,  _} = Integer.parse(ttl)
    :timer.sleep(:timer.seconds(ttl))
    Storage.delete_key(Storage.kvstore_name(), key)
    Logger.info("Removed #{key} after #{ttl} seconds")
  end

  def check_ttl_in_dets do
    keys_ttl_pair = Storage.match_params(Storage.kvstore_name(), {:"$1", :_, :"$2"})
    Enum.each(keys_ttl_pair, fn([key, ttl]) -> run_async_task(key, ttl) end)
  end

  def run_async_task(key, ttl) do
    Task.async(__MODULE__, :remove, [key, ttl])
  end
end
