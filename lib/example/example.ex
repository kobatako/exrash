defmodule Exrash.Example do

  def sample_call() do
    Exrash.start
    Exrash.Provider.set_configure(
      %Exrash.Provider{
        http: "http://192.168.33.142",
        init_proc: 5, interval_time: 1, interval_count: 2, add_proc: 5}
    )
    Exrash.Provider.start_request
  end
end
