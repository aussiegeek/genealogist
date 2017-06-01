defmodule Genealogist do
  @moduledoc """
  Interrogate a supervisor for all of it's descendants and write a Graphviz graph of the results to disk

  It finds the tree of all of it's children, finds any names use to name the children, and then lastly for any process registries found, it will go lookup it's names in those registries as well
  """

  alias Genealogist.{Builder, Graphviz}
  def write_graph(supervisor, format, filename) do
    supervisor
    |> Builder.tree()
    |> Graphviz.graph()
    |> Dotex.write_graph(format, filename)
  end
end
