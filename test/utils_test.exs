defmodule KVstore.UtilsTest do
  use ExUnit.Case
  use Plug.Test
  require Logger
  doctest KVstore.Utils

  alias KVstore.Utils

  test "remove key after ttl" do
    {:ok, table} = Utils.open_table()
    :dets.insert_new(table, {"test_key", "test_value", "1"})
    assert :dets.match(:kvstore_test, {:"$1", :"_", :"_"}) == [["test_key"]]
    Utils.remove("test_key", "1")
    :timer.sleep(:timer.seconds(3))
    assert :dets.match(:kvstore_test, {:"$1", :"_", :"_"}) == []
  end

  test "remove record after ttl on async task" do
    {:ok, table} = Utils.open_table()
    :dets.insert_new(table, {"test_key", "test_value", "1"})
    Utils.check_ttl_in_dets()
    :timer.sleep(:timer.seconds(3))
    assert :dets.match(:kvstore_test, {:"$1", :"_", :"_"}) == []
  end
end
