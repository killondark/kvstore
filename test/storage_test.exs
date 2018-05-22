defmodule KVstore.StorageTest do
  use ExUnit.Case
  use Plug.Test
  require Logger
  doctest KVstore.Storage

  alias KVstore.Storage
  alias KVstore.Router

  @opts Storage.init([])

  setup do
    KVstore.Utils.open_table()
    :dets.delete(:kvstore, "test_key")
  end

  test "returns new.html" do
    html =
      "<h1>New key value</h1>\n<form action=\"/create\" method=\"post\">\n  Key<br>\n  " <>
      "<input type=\"text\" name=\"key\"><br><br>\n  Value<br>\n  <input type=\"text\" " <>
      "name=\"value\"><br><br>\n  TTL in seconds<br>\n  <input type=\"text\" name=\"ttl\">\n  " <>
      "<p><input type=\"submit\"></p>\n</form>\n"
    response =
      conn(:get, "/new", "")
      |> Router.call(@opts)
    assert response.resp_body == html
  end

  test "create record in dets table" do
    assert :dets.match(:kvstore, {:"$1", :"_", :"_"}) == []
    conn(:post, "/create", %{"key" => "test_key", "value" => "test_value", "ttl" => "10"})
    |> Router.call(@opts)
    assert :dets.match(:kvstore, {:"$1", :"_", :"_"}) == [["test_key"]]
  end

  test "delete record in dets table" do
    assert :dets.match(:kvstore, {:"$1", :"_", :"_"}) == []
    conn(:post, "/create", %{"key" => "test_key", "value" => "test_value", "ttl" => "1"})
    |> Router.call(@opts)
    assert :dets.match(:kvstore, {:"$1", :"_", :"_"}) == [["test_key"]]

    :timer.sleep(:timer.seconds(2))
    assert :dets.match(:kvstore, {:"$1", :"_", :"_"}) == []
  end
end
