defmodule KVstore.StorageTest do
  use ExUnit.Case
  use Plug.Test
  require Logger
  doctest KVstore.Storage

  alias KVstore.Storage
  alias KVstore.Router

  @opts Storage.init([])

  setup do
    :dets.open_file(:kvstore_test, [type: :set])
    keys = List.flatten(Storage.match_params(:kvstore_test, {:"$1", :"_", :"_"}))
    Enum.each(keys, fn(key) -> Storage.delete_key(:kvstore_test, key) end)
  end

  # action new
  test "returns new message" do
    result = "You can make request to create action with params"
    response =
      conn(:get, "/new", "")
      |> Router.call(@opts)
    assert response.resp_body == result
  end

  # action index
  test "returns dets record after create" do
    assert Storage.match_params(:kvstore_test, {:"$1", :"_", :"_"}) == []
    conn(:post, "/create", %{"key" => "test_key", "value" => "value", "ttl" => "10"})
    |> Router.call(@opts)
    result = "Listing kvstore records\n[[\"test_key\", \"value\", \"10\"]]"
    response =
      conn(:get, "/index", "")
      |> Router.call(@opts)
    assert response.resp_body == result
  end

  # action create
  test "create record in dets table" do
    assert Storage.match_params(:kvstore_test, {:"$1", :"_", :"_"}) == []
    conn(:post, "/create", %{"key" => "test_key", "value" => "test_value", "ttl" => "10"})
    |> Router.call(@opts)
    assert Storage.match_params(:kvstore_test, {:"$1", :"_", :"_"}) == [["test_key"]]
  end

  # action destroy
  test "delete record in dets table" do
    assert Storage.match_params(:kvstore_test, {:"$1", :"_", :"_"}) == []
    conn(:post, "/create", %{"key" => "test_key", "value" => "test_value", "ttl" => "1"})
    |> Router.call(@opts)
    assert Storage.match_params(:kvstore_test, {:"$1", :"_", :"_"}) == [["test_key"]]

    :timer.sleep(:timer.seconds(2))
    assert Storage.match_params(:kvstore_test, {:"$1", :"_", :"_"}) == []
  end

  # action show
  test "show record in dets table" do
    assert Storage.match_params(:kvstore_test, {:"$1", :"_", :"_"}) == []
    conn(:post, "/create", %{"key" => "test_key", "value" => "test_value", "ttl" => "1"})
    |> Router.call(@opts)
    result = "Show kvstore record\n[{\"test_key\", \"test_value\", \"1\"}]"

    response =
      conn(:get, "/show/test_key")
      |> Router.call(@opts)
    assert response.resp_body == result
  end

  # action update
  test "update record in dets table" do
    assert Storage.match_params(:kvstore_test, {:"$1", :"_", :"_"}) == []
    conn(:post, "/create", %{"key" => "test_key", "value" => "test_value", "ttl" => "1"})
    |> Router.call(@opts)

    response =
      conn(:put, "/update/test_key", %{"key" => "test_key", "value" => "updated_test_value", "ttl" => "1"})
      |> Router.call(@opts)
    assert response.resp_body == "Updated in DETS"
    assert Storage.match_params(:kvstore_test, {:"_", :"$1", :"_"}) == [["updated_test_value"]]
  end
end
