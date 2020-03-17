defmodule Exrash.Exporter.ExporterBehaviour do

  alias Exrash.Report.Record

  @callback export(%Record{}) :: { :ok }
end
