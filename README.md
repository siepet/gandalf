# Gandalf

Gandalf is a protector plug that keeps away all unwanted visitors.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gandalf` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:gandalf, "~> 0.1.0"}]
end
```

Add plug to endpoint file before router:
```
Plug Gandalf
Plug YourApp.Router
```

## Configuration

Two ways to configure Gandalf:
1. In `config/config.exs` (or any other env-config)
```
config :gandalf, auth_key: "auth_key_goes_here"
```

2. When adding a plug inside endpoint file, provide auth_key param:
```
Plug Gandalf, auth_key: "auth_key_goes_here"
```


### Whitelisting
Paths:
To whitelist paths, simply provide `whitelistd_paths: ~r/path1|path2/` to config.

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
