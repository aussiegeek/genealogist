defmodule Genealogist.CitiesChildrenSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: Genealogist.CitiesChildrenSupervisor)
  end

  def init([]) do
    children = [
      worker(Genealogist.CityWorker, []),
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
