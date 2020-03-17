defmodule Exrash.Client.HttpClient do

  use HTTPoison.Base

  def process_response_body(body) do
    body
  end
end
