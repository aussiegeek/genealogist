defmodule Genealogist.CountriesChildrenSupervisor do
  @moduledoc false
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: Genealogist.CountriesChildrenSupervisor)
  end

  def init([]) do
    children = [
      worker(Genealogist.CountryWorker, []),
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
