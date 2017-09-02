defmodule Gandalf do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, options) do
    conn
    |> check_access(options)
  end

  defp check_access(conn, options) do
    case check_cookie(conn, options) do
      true -> conn
      false -> handle_unauthorized_access(conn, options)
    end
  end

  defp check_cookie(conn, options) do
    conn = fetch_cookies(conn)
    conn.cookies["auth_key"] == options[:auth_key]
  end

  defp handle_unauthorized_access(conn, options) do
    case conn.method do
      "POST" -> handle_form_submit(conn, options)
      _ -> render_form(conn)
    end
  end

  # TODO:
  defp handle_form_submit(conn, _options) do
    conn = parse_body(conn)
  end

  # NOTE: manual Plug call
  defp parse_body(conn) do
    opts = [parsers: [Plug.Parsers.URLENCODED]]
    Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  end

  defp render_form(conn) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_body())
  end

  defp html_body do
    {:ok, body} = File.read("lib/form.html")
    body
  end
end
