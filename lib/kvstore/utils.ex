defmodule KVstore.Utils do
  require Logger

  def parse(conn, opts \\ []) do
    opts = Keyword.put_new(opts, :parsers, [Plug.Parsers.URLENCODED, Plug.Parsers.MULTIPART])
    Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  end

  def remove(key, ttl) do
    {ttl,  _} = Integer.parse(ttl)
    :timer.sleep(:timer.seconds(ttl))
    :dets.delete(kvstore_name(), key)
    Logger.info("Removed #{key} after #{ttl} seconds")
  end

  def open_table do
    :dets.open_file(kvstore_name(), [type: :set])
  end

  def close_table do
    :dets.close(kvstore_name())
  end

  def check_ttl_in_dets do
    keys_ttl_pair = :dets.match(kvstore_name(), {:"$1", :"_", :"$2"})
    Enum.each(keys_ttl_pair, fn([key, ttl]) -> run_async_task(key, ttl) end)
  end

  def run_async_task(key, ttl) do
    Task.async(__MODULE__, :remove, [key, ttl])
  end

  def kvstore_name do
    Application.fetch_env!(:kvstore, :dets)
  end
end
