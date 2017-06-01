defmodule Genealogist.CountryWorker do
  @moduledoc nil
  use GenServer

  def start_link(name), do: GenServer.start_link(__MODULE__, name, name: {:via, Registry, {Genealogist.Registry, {:country, name}}})

  def init(name), do: {:ok, name}
end
