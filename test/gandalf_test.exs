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
end
