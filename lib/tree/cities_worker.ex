defmodule Genealogist.CitiesWorker do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: Genealogist.CitiesWorker)

  def init(:ok) do
    {:ok, _} = Supervisor.start_child(Genealogist.CitiesChildrenSupervisor, ["Melbourne"])
    {:ok, :nil_state}
  end
end
