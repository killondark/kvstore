defmodule KVstore do
  use Application
  require Logger

  def start(_type, _args) do
    port = Application.get_env(KVstore.Storage.kvstore_name(), :cowboy_port, 8080)
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, KVstore.Router, [], port: port)
    ]
    KVstore.Storage.open_table()
    Logger.info("Started application")
    Task.async(KVstore.Utils, :check_ttl_in_dets, [])
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
