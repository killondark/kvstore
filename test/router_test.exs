defmodule KVstore.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias KVstore.Router

  @opts Router.init([])

  test "returns welcome" do
    conn =
      conn(:get, "/", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Welcome to KVstore"
  end

  test "Favicon spike" do
    conn =
      conn(:get, "/favicon.ico", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Favicon spike"
  end

  test "go to new action" do
    conn =
      conn(:get, "/new", "")
      |> put_resp_header("content-type", "text/html; charset=utf-8")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "go to index action" do
    conn =
      conn(:get, "/index", "")
      |> put_resp_header("content-type", "text/html; charset=utf-8")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "go to show action" do
    conn =
      conn(:get, "/show/key", "")
      |> put_resp_header("content-type", "text/html; charset=utf-8")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "go to update action" do
    conn =
      conn(:put, "/update/key", %{"key" => "new_key", "value" => "new_value", "ttl" => "10"})
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "go to destroy action" do
    conn =
      conn(:delete, "/destroy/key", %{"key" => "key", "value" => "value", "ttl" => "10"})
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "go to create action" do
    conn =
      conn(:post, "/create", %{"key" => "test_key", "value" => "test_value", "ttl" => "10"})
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "returns 404" do
    conn =
      conn(:get, "/missing", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Oops!"
  end
end
