defmodule Gandalf do
  import IEx
  use Plug.Builder

  def call(conn, options) do
    conn
    |> check_access(options)
  end

  defp check_access(conn, options) do
    case check_cookie(conn, options) do
      true -> conn
      false -> check_whitelisted_paths(conn, options)
    end
  end

  defp check_cookie(conn, options) do
    conn = fetch_cookies(conn)
    conn.cookies["auth_key"] == auth_key(options)
  end

  def check_whitelisted_paths(conn, options) do
    case Regex.match?(whitelisted_paths(options), conn.request_path) do
      true -> conn
      false -> handle_unauthorized_access(conn, options)
    end
  end

  defp handle_unauthorized_access(conn, options) do
    case conn.method do
      "POST" -> handle_form_submit(conn, options)
      _ -> render_form(conn)
    end
  end

  defp handle_form_submit(conn, options) do
    conn = Plug.Parsers.call(conn, options)
    case conn.params["code"] == auth_key(options) do
      true -> handle_proper_key(conn)
      false -> render_form(conn)
    end
  end

  defp handle_proper_key(conn) do
    conn
      |> put_resp_cookie("auth_key", conn.params["code"])
      |> put_resp_header("location", "/")
      |> send_resp(302, "text/html")
  end

  defp auth_key(opts) do
    Application.get_env(:gandalf, :auth_key) || opts[:auth_key] || "auth_key"
  end

  def whitelisted_paths(opts) do
    Application.get_env(:gandalf, :whitelisted_paths) || opts[:whitelisted_paths]
  end

  defp render_form(conn) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_body())
  end

  defp html_body do
    {:ok, body} = File.read(Path.join(:code.priv_dir(:gandalf), "form.html"))
    body
  end
end
