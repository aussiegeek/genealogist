defmodule Genealogist.Builder do

  def tree(supervisor) do
    supervisor
    |> build_tree
    |> find_registries
    |> add_names
  end

  defp build_tree(supervisor) when is_atom(supervisor), do: [process_supervisor(Process.whereis(supervisor))]

  defp process_supervisor(pid) when is_pid(pid) do
    {:supervisor, pid, build_children(pid)}
  end

  defp build_children(supervisor) do
    supervisor
    |> Supervisor.which_children
    |> process_children
    |> Enum.reverse
  end

  defp process_children([]), do: []
  defp process_children([{_id, pid, :worker, _modules}|t]) do
    [{:worker, pid}|process_children(t)]
  end
  defp process_children([{Registry, pid, :supervisor, [Registry]}|_]) do
    [{:registry, :erlang.process_info(pid)[:registered_name]}]
  end
  defp process_children([{_id, pid, :supervisor, _modules}|t]) do
    [process_supervisor(pid)|process_children(t)]
  end

  defp find_registries(tree), do: {Enum.reduce(tree, [], &find_registries/2), tree}
  defp find_registries({:registry, name}, registries), do: [name|registries]
  defp find_registries({:worker, _}, registries), do: registries
  defp find_registries({:supervisor, _pid, children}, registries) do
    Enum.reduce(children, registries, &find_registries/2)
  end


  defp add_names({supervisors, tree}) do
    {supervisors, add_process_name(supervisors, tree)}
  end

  defp add_process_name(_registires, []), do: []
  defp add_process_name(registries, [{:worker, pid}|t]) do
    [{:worker, process_names(registries, pid)}|add_process_name(registries, t)]
  end
  defp add_process_name(registries, [{:supervisor, pid, children}|t]) do
    [{:supervisor, process_names(registries, pid), add_process_name(registries, children)}|add_process_name(registries, t)]
  end
  defp add_process_name(registries, [{:registry, _name}|t]) do
    add_process_name(registries, t)
  end

  defp process_names(registries, pid) when is_pid(pid) do
    name = :erlang.process_info(pid)[:registered_name]
    names = case name do
      nil -> []
      _ -> [name]
    end

    all_names = [names | registry_names(registries, pid)] |> List.flatten

    case all_names do
      [] -> ["Untitled"]
      _ -> all_names
    end
  end

  defp registry_names(registries, pid) when is_pid(pid) and is_list(registries) do
    registries
    |> Enum.map(fn(registry) -> registry_names(registry, pid) end)
  end

  defp registry_names(registry, pid) when is_atom(registry) do
    registry
    |> Registry.keys(pid)
    |> Enum.map(fn(name) -> {:registry, registry, name} end)
  end
end
