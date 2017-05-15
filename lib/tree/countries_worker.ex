defmodule Genealogist.CountriesWorker do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: Genealogist.CountriesWorker)

  def init(:ok) do
    {:ok, _} = Supervisor.start_child(Genealogist.CountriesChildrenSupervisor, ["Australia"])
    {:ok, _} = Supervisor.start_child(Genealogist.CountriesChildrenSupervisor, ["New Zealand"])
    {:ok, :nil_state}
  end
end
