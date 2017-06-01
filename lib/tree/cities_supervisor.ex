defmodule Genealogist.CitiesSupervisor do
  @moduledoc nil
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: Genealogist.CitiesSupervisor)
  end

  def init([]) do
    children = [
      supervisor(Genealogist.CitiesChildrenSupervisor, []),
      worker(Genealogist.CitiesWorker, []),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
