defmodule Exrash.Report.Record do
  defstruct start: nil, end: nil, body: "", status_code: 0, request: "", headers: []

  def new(state, from, to) do
    %Exrash.Report.Record{
      body: state.body,
      status_code: state.status_code,
      request: state.request,
      headers: state.headers,
      start: from,
      end: to
    }
  end
end
