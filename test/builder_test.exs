defmodule BuilderTest do
  use ExUnit.Case

  alias Genealogist.{Builder}

  setup_all do
    {:ok, _pid} = Genealogist.PlacesSupervisor.start_link

    :ok
  end

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
            {:supervisor, [Genealogist.CitiesChildrenSupervisor],
             [
               {:worker, ["Untitled"]},
             ]
            },
            {:worker, [Genealogist.CitiesWorker]}
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
                {:supervisor, [Genealogist.CitiesChildrenSupervisor],
                 [
                   {:worker, [{:registry, Genealogist.Registry, "Cities!Melbourne"}]},
                 ]
                },
                {:worker, [Genealogist.CitiesWorker]}
              ]
            }
          ]
        }
      ]
    }
  end
end
