defmodule GandalfTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @with_authkey Gandalf.init(%{auth_key: "1234"})
  @with_whitelisted_path Gandalf.init(%{whitelisted_paths: ~r/path/})
  @with_whitelisted_ip Gandalf.init(%{whitelisted_ips: ["80.123.123.123"]})

  test "returns form when no valid auth_key cookie" do
    conn = conn(:get, "/")

    conn = Gandalf.call(conn, @with_authkey)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body =~ "Sign in"
  end

  test "returns conn when valid auth_key cookie" do
    conn = conn(:get, "/")
    conn = conn |> put_resp_cookie("auth_key", "1234")

    conn = Gandalf.call(conn, @with_authkey)

    assert conn.state == :unset
  end

  test "returns conn when valid auth_key provided in form" do
    conn = conn(:post, "/", code: "1234")

    conn = Gandalf.call(conn, @with_authkey)

    assert conn.state == :sent
  end

  test "sets proper cookie if valid auth key " do
    conn = conn(:post, "/", code: "1234")

    conn = Gandalf.call(conn, @with_authkey)

    conn = fetch_cookies(conn)

    assert conn.cookies["auth_key"] == "1234"
  end

  test "renders form when invalid auth key sent in form" do
    conn = conn(:post, "/", code: "invalid")

    conn = Gandalf.call(conn, @with_authkey)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body =~ "Sign in"
  end

  test "lets pass through when accessing whitelisted path" do
    conn = conn(:get, "/path")

    conn = Gandalf.call(conn, @with_whitelisted_path)

    assert conn.state == :unset
  end

  test "lets pass through when accessing with whitelisted ip" do
    conn = %{ conn(:get, "/") | remote_ip: {80, 123, 123, 123}}

    conn = Gandalf.call(conn, @with_whitelisted_ip)

    assert conn.state == :unset
  end

  test "renders form when no whitelisted ip" do
    conn = %{ conn(:get, "/") | remote_ip: {80, 321, 321, 321}}

    conn = Gandalf.call(conn, @with_whitelisted_ip)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body =~ "Sign in"
  end
end
