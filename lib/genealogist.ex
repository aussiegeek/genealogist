defmodule Genealogist do
  @moduledoc """
  Interrogate a supervisor for all of it's descendants and write a Graphviz graph of the results to disk

  It finds the tree of all of it's children, finds any names use to name the children, and then lastly for any process registries found, it will go lookup it's names in those registries as well
  """

  alias Genealogist.{Builder, Graphviz}

  @doc """
  Take a `Supervisor` and write a Graphviz representation of it to disk

  ## Attributes
  * `supervisor` - name of the supervisor to build a graph for
  * `format` - atom representing the desired output format, (eg. :png, :svg, :dot)
  * `filename` - path to write the graph to
  """
  def write_graph(supervisor, format, filename) do
    supervisor
    |> Builder.tree()
    |> Graphviz.graph()
    |> Dotex.write_graph(format, filename)
  end
end
