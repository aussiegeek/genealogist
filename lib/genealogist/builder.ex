defmodule Genealogist.Builder do
  @moduledoc """
  Interrogate a supervisor for all of it's descendants.

  It finds the tree of all of it's children, finds any names use to name the children, and then lastly for any process registries found, it will go lookup it's names in those registries as well
  """

  @doc """
  Take a supervisor, fetch all of it's children, and any names they have in any registries found along the way

  ## Attributes
  * `supervisor` - the name of the top level supervisor
  """
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
    |> Enum.map(&process_child/1)
  end

  defp process_child({_id, pid, :worker, _modules}), do: {:worker, pid}
  defp process_child({Registry, pid, :supervisor, [Registry]}), do: {:registry, :erlang.process_info(pid)[:registered_name]}
  defp process_child({_id, pid, :supervisor, _modules}), do: process_supervisor(pid)

  defp find_registries(tree), do: {Enum.reduce(tree, [], &find_registries/2), tree}
  defp find_registries({:registry, name}, registries), do: [name|registries]
  defp find_registries({:worker, _}, registries), do: registries
  defp find_registries({:supervisor, _pid, children}, registries) do
    Enum.reduce(children, registries, &find_registries/2)
  end

  defp add_names({registries, tree}) do
    {registries, add_process_name_to_children(registries, tree)}
  end

  defp add_process_name_to_children(registries, children) do
    children
    |> Enum.map(fn(child) -> add_process_name(registries, child) end)
    |> Enum.reject(&is_nil/1)
  end

  defp add_process_name(registries, {:worker, pid}), do: {:worker, process_names(registries, pid)}
  defp add_process_name(registries, {:supervisor, pid, children}) do
    {:supervisor, process_names(registries, pid), add_process_name_to_children(registries, children)}
  end
  defp add_process_name(_registries, {:registry, _name}), do: nil

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
