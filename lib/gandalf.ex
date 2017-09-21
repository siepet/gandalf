defmodule Gandalf do
  use Plug.Builder

  def call(conn, options) do
    conn
    |> check_access(options)
  end

  defp check_access(conn, options) do
    case valid?(conn, options) do
      true -> conn
      false -> handle_unauthorized_access(conn, options)
    end
  end

  defp valid?(conn, options) do
    paths = whitelisted_paths(options)
    ips = whitelisted_ips(options)

    valid_cookie?(conn, options) || valid_path?(conn, options, paths) || valid_ip?(conn, options, ips)
  end

  defp valid_cookie?(conn, options) do
    conn = fetch_cookies(conn)
    conn.cookies["auth_key"] == auth_key(options)
  end

  defp valid_path?(_conn, _options, nil), do: false
  defp valid_path?(conn, _options, paths) do
    Regex.match?(paths, conn.request_path)
  end

  defp valid_ip?(_conn, _options, nil), do: false
  defp valid_ip?(conn, _options, ips) do
    remote_ip = to_string(:inet_parse.ntoa(conn.remote_ip))
    Enum.member?(ips, remote_ip)
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
      |> halt
  end

  defp auth_key(opts) do
    Application.get_env(:gandalf, :auth_key) || opts[:auth_key] || "auth_key"
  end

  defp whitelisted_paths(opts) do
    Application.get_env(:gandalf, :whitelisted_paths) || opts[:whitelisted_paths]
  end

  defp whitelisted_ips(opts) do
    Application.get_env(:gandalf, :whitelisted_ips) || opts[:whitelisted_ips]
  end

  defp render_form(conn) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_body())
    |> halt
  end

  defp html_body do
    {:ok, body} = File.read(Path.join(:code.priv_dir(:gandalf), "form.html"))
    body
  end
end
