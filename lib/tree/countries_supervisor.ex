defmodule Genealogist.CountriesSupervisor do
  @moduledoc nil
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: Genealogist.CountriesSupervisor)
  end

  def init([]) do
    children = [
      supervisor(Genealogist.CountriesChildrenSupervisor, []),
      worker(Genealogist.CountriesWorker, []),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
