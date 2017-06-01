defmodule Genealogist.CitiesWorker do
  @moduledoc nil
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: Genealogist.CitiesWorker)

  def init(:ok) do
    {:ok, _} = Supervisor.start_child(Genealogist.CitiesChildrenSupervisor, ["Melbourne"])
    {:ok, _} = Supervisor.start_child(Genealogist.CitiesChildrenSupervisor, ["William Creek"])
    {:ok, :nil_state}
  end
end
