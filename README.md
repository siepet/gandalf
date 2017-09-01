# Gandalf

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gandalf` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:gandalf, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/gandalf](https://hexdocs.pm/gandalf).


## Development

Run plug application for development:
```
$ iex -S mix
iex> c "lib/gandalf.ex"
iex> {:ok, _} = Plug.Adapters.Cowboy.http Gandalf, %{auth_key: "1234"}
```
Access http://localhost:4000
