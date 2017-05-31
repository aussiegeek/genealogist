defmodule Genealogist.GraphvizTest do
  use ExUnit.Case
  alias Genealogist.Graphviz
  alias Dotex.Node

  defp supervisor_attributes, do: [shape: "box"]

  test "generate simple graph" do
    {:ok, _pid} = Genealogist.EmptySupervisor.start_link
    tree = Genealogist.Builder.tree(Genealogist.EmptySupervisor)
    assert Graphviz.graph(tree) == %Dotex.Graph{
      attributes: [rankdir: "LR"],
      nodes: [
        Dotex.Node.new("Genealogist.EmptySupervisor", supervisor_attributes())
      ],
      connections: [],
    }
  end

  test "supervision tree with registry" do
    tree = Genealogist.Builder.tree(Genealogist.CitiesSupervisor)
    assert Graphviz.graph(tree) == %Dotex.Graph{
      attributes: [rankdir: "LR"], id: nil, type: "digraph",
      connections: [
        {
          Node.new("Genealogist.CitiesChildrenSupervisor", supervisor_attributes()),
         [
           Node.new("Untitled"),
           Node.new("Untitled")
         ], []
        },
        {
          Node.new("Genealogist.CitiesSupervisor", supervisor_attributes()),
          [
            Node.new("Genealogist.CitiesWorker"),
            Node.new("Genealogist.CitiesChildrenSupervisor", supervisor_attributes())
          ],
          []
        }
      ],
      nodes: [
        Node.new("Genealogist.CitiesSupervisor", supervisor_attributes()),
        Node.new("Genealogist.CitiesWorker"),
        Node.new("Genealogist.CitiesChildrenSupervisor", supervisor_attributes()),
        Node.new("Untitled"),
        Node.new("Untitled")
      ]
    }
  end

  test "supervision tree with no registry" do
    tree = Genealogist.Builder.tree(Genealogist.PlacesSupervisor)
    assert Graphviz.graph(tree) == %Dotex.Graph{
      type: "digraph", attributes: [rankdir: "LR"],
      nodes: [
        Node.new("Genealogist.PlacesSupervisor", supervisor_attributes()),
        Node.new("Genealogist.CitiesSupervisor", supervisor_attributes()),
        Node.new("Genealogist.CitiesWorker"),
        Node.new("Genealogist.CitiesChildrenSupervisor", supervisor_attributes()),
        Node.new(~s({:registry, Genealogist.Registry, "Cities!Melbourne"})),
        Node.new(~s({:registry, Genealogist.Registry, "Cities!William Creek"})),
        Node.new("Genealogist.CountriesSupervisor", supervisor_attributes()),
        Node.new("Genealogist.CountriesWorker"),
        Node.new("Genealogist.CountriesChildrenSupervisor", supervisor_attributes()),
        Node.new(~s({:registry, Genealogist.Registry, {:country, "Australia"}})),
        Node.new(~s({:registry, Genealogist.Registry, {:country, "New Zealand"}})),
      ],
      connections: [{%Dotex.Node{attributes: [shape: "box"], name: "Genealogist.CountriesChildrenSupervisor"}, [%Dotex.Node{attributes: [], name: "{:registry, Genealogist.Registry, {:country, \"Australia\"}}"}, %Dotex.Node{attributes: [], name: "{:registry, Genealogist.Registry, {:country, \"New Zealand\"}}"}], []}, {%Dotex.Node{attributes: [shape: "box"], name: "Genealogist.CountriesSupervisor"}, [%Dotex.Node{attributes: [], name: "Genealogist.CountriesWorker"}, %Dotex.Node{attributes: [shape: "box"], name: "Genealogist.CountriesChildrenSupervisor"}], []}, {%Dotex.Node{attributes: [shape: "box"], name: "Genealogist.CitiesChildrenSupervisor"}, [%Dotex.Node{attributes: [], name: "{:registry, Genealogist.Registry, \"Cities!Melbourne\"}"}, %Dotex.Node{attributes: [], name: "{:registry, Genealogist.Registry, \"Cities!William Creek\"}"}], []}, {%Dotex.Node{attributes: [shape: "box"], name: "Genealogist.CitiesSupervisor"}, [%Dotex.Node{attributes: [], name: "Genealogist.CitiesWorker"}, %Dotex.Node{attributes: [shape: "box"], name: "Genealogist.CitiesChildrenSupervisor"}], []}, {%Dotex.Node{attributes: [shape: "box"], name: "Genealogist.PlacesSupervisor"}, [%Dotex.Node{attributes: [shape: "box"], name: "Genealogist.CitiesSupervisor"}, %Dotex.Node{attributes: [shape: "box"], name: "Genealogist.CountriesSupervisor"}], []}],
    }
  end
end
