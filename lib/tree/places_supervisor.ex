defmodule Genealogist.PlacesSupervisor do
  @moduledoc nil
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: Genealogist.PlacesSupervisor)
  end

  def init([]) do
    children = [
      supervisor(Registry, [:unique, Genealogist.Registry]),
      supervisor(Genealogist.CountriesSupervisor, []),
      supervisor(Genealogist.CitiesSupervisor, []),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
