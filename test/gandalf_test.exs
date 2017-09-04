defmodule GandalfTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Gandalf.init(%{auth_key: "1234"})

  test "returns form when no valid auth_key cookie" do
    conn = conn(:get, "/")

    conn = Gandalf.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body =~ "Sign in"
  end

  test "returns conn when valid auth_key cookie" do
    conn = conn(:get, "/")
    conn = conn |> put_resp_cookie("auth_key", "1234")

    conn = Gandalf.call(conn, @opts)

    assert conn.state == :unset
  end

  test "returns conn when valid auth_key provided in form" do
    conn = conn(:post, "/", code: "1234")

    conn = Gandalf.call(conn, @opts)

    assert conn.state == :sent
  end

  test "sets proper cookie if valid auth key " do
    conn = conn(:post, "/", code: "1234")

    conn = Gandalf.call(conn, @opts)

    conn = fetch_cookies(conn)

    assert conn.cookies["auth_key"] == "1234"
  end

  test "renders form when invalid auth key sent in form" do
    conn = conn(:post, "/", code: "invalid")

    conn = Gandalf.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body =~ "Sign in"
  end
end
