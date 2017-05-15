defmodule Genealogist do
  def write_graph(supervisor, format, filename) do
    supervisor
    |> Genealogist.Builder.tree()
    |> Genealogist.Graphviz.graph()
    |> Dotex.write_graph(format, filename)
  end
end
