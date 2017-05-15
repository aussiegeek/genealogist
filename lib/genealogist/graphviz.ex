defmodule Genealogist.Graphviz do
  def graph({_registries, tree}) do
    anotated_nodes = add_nodes(tree)
    %Dotex.Graph{nodes: List.flatten(extract_nodes(anotated_nodes)), attributes: [rankdir: "LR"]}
    |> add_connections(anotated_nodes)
  end

  defp add_nodes([]), do: []
  defp add_nodes([{:supervisor, names, children}|t]) do
    [{:supervisor, Dotex.Node.new(node_name(names), node_attributes(:supervisor)), add_nodes(children)}|add_nodes(t)]
  end
  defp add_nodes([{:worker, names}|t]), do: [{:worker, Dotex.Node.new(node_name(names), node_attributes(:worker))}|add_nodes(t)]

  defp node_attributes(:supervisor), do: [shape: "box"]
  defp node_attributes(:worker), do: []

  # TODO: probably need a better name extractor
  defp node_name(["Untitled"]), do: "Untitled"
  defp node_name(names), do: inspect names |> Enum.at(0)

  defp extract_nodes([]), do: []
  defp extract_nodes([{:worker, node}|t]), do: [node|extract_nodes(t)]
  defp extract_nodes([{:supervisor, node, children}|t]) do
    [node|[extract_nodes(children)|extract_nodes(t)]]
  end
  defp add_connections(graph, []), do: graph
  defp add_connections(graph, [{:worker, _node}|t]), do: add_connections(graph, t)
  defp add_connections(graph, [{:supervisor, _node, []}|t]), do: add_connections(graph, t)
  defp add_connections(graph, [{:supervisor, node, children}|t]) do
    child_nodes = Enum.map(children, fn(child) -> elem(child, 1) end)
    Dotex.Graph.add_connection(graph, node, child_nodes)
    |> add_connections(children)
    |> add_connections(t)
  end
end
