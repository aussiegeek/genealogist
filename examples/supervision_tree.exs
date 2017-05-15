{:ok, _pid} = Genealogist.PlacesSupervisor.start_link

Genealogist.write_graph(Genealogist.PlacesSupervisor, "png", "supervision_tree.png")
