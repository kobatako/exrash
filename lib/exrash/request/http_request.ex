defmodule Exrash.Request.HttpRequest do
  @doc """
  call request http client
  """

  alias Exrash.Client.HttpClient

  @spec call_request({ HTTPoison.Request.method(), HTTPoison.Request.url() | %URI{}, HTTPoison.Request.headers()})
          :: { HTTPoison.Response.t() | nil, DateTime.t() | nil, DateTime.t() | nil }
  def call_request({method, url, headers}), do: call_request(method, url, headers)

  @spec call_request(HTTPoison.Request.method(), HTTPoison.Request.url() | %URI{}, HTTPoison.Request.headers() | nil)
          :: { HTTPoison.Response.t() | nil, DateTime.t() | nil, DateTime.t() | nil }
  def call_request(:get, %URI{}=url, headers), do: call_request(:get, to_string(url), headers)
  def call_request(method, http, nil), do: call_request(method, http, [])
  def call_request(:get, http, headers) do
    from = Timex.now
    res = HttpClient.get!(http, headers)
    to = Timex.now
    {res, from, to}
  end

  def call_request(_, _, _), do: {nil, nil, nil}

end
