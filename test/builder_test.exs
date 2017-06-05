defmodule BuilderTest do
  use ExUnit.Case

  alias Genealogist.{Builder}

  test "single supervisor with no registry or children" do
    {:ok, _pid} = Genealogist.EmptySupervisor.start_link
    assert Builder.tree(Genealogist.EmptySupervisor) == {[], [{:supervisor, [Genealogist.EmptySupervisor], []}]}
  end

  test "supervision tree with no registry" do
    assert Builder.tree(Genealogist.CitiesSupervisor) == {
      [],
      [
        {
          :supervisor,
          [Genealogist.CitiesSupervisor],
          [
            {:worker, [Genealogist.CitiesWorker]},
            {:supervisor, [Genealogist.CitiesChildrenSupervisor],
             [{:worker, ["Untitled"]},{:worker, ["Untitled"]}]
            },
          ]
        }
      ]
    }
  end

  test "supervision tree with registry" do
    assert Builder.tree(Genealogist.PlacesSupervisor) == {
      [Genealogist.Registry],
      [
        {
          :supervisor,
          [Genealogist.PlacesSupervisor],
          [
            {
              :supervisor,
              [Genealogist.CitiesSupervisor],
              [
                {:worker, [Genealogist.CitiesWorker]},
                {:supervisor, [Genealogist.CitiesChildrenSupervisor],
                 [
                   {:worker, [{:registry, Genealogist.Registry, "Cities!Melbourne"}]},
                   {:worker, [{:registry, Genealogist.Registry, "Cities!William Creek"}]},
                 ]
                },
              ]
            },
            {
              :supervisor,
              [Genealogist.CountriesSupervisor],
              [
                {:worker, [Genealogist.CountriesWorker]},
                {:supervisor, [Genealogist.CountriesChildrenSupervisor],
                 [
                   {:worker, [{:registry, Genealogist.Registry, {:country, "New Zealand"}}]},
                   {:worker, [{:registry, Genealogist.Registry, {:country, "Australia"}}]},
                 ]
                }
              ]
            }
          ]
        }
      ]
    }
  end
end
