defmodule Genealogist.CityWorker do
  use GenServer

  def start_link(name), do: GenServer.start_link(__MODULE__, name, name: {:via, Registry, {Genealogist.Registry, "Cities!" <> name}})

  def init(name), do: {:ok, name}
end
