defmodule VKAPI.Macro do
  @schema_path "./methods.json"

  defmacro __using__(_options) do
    method_group_list()
    |> create_methods()
    |> create_modules()
  end

  defp create_modules(array) do
    Enum.each(array, fn {methods, module} ->
      Module.create(module, methods, Macro.Env.location(__ENV__))
    end)
  end

  @spec create_methods(any) :: [any]
  defp create_methods(schema) do
    Enum.map(schema, fn {module, methods} ->
      {quote bind_quoted: [module: module, methods: methods] do
         Enum.map(methods, fn {name, formatted, description} ->
           @doc description
           def unquote(formatted)(params \\ %{}) do
             VKAPI.Request.request("#{unquote(module)}.#{unquote(name)}", params)
           end
         end)
       end, format_module(module)}
    end)
  end

  defp format_module(module) do
    module
    |> Macro.camelize()
    |> (&("Elixir.VKAPI." <> &1)).()
    |> String.to_atom()
  end

  defp format_name(name) do
    name
    |> Macro.underscore()
    |> String.to_atom()
  end

  defp method_group_list do
    methods_map()
    |> Enum.map(&process_fields/1)
    |> group()
  end

  defp methods_map do
    methods_json()
    |> Jason.decode!()
    |> Map.get("methods")
  end

  defp methods_json do
    case File.read(@schema_path) do
      {:ok, content} -> content
      {:error, _} -> github_schema()
    end
  end

  defp github_schema do
    {:ok, {_, _, content}} =
      :httpc.request('https://raw.githubusercontent.com/VKCOM/vk-api-schema/master/methods.json')

    content
  end

  defp process_fields(method) do
    [module, name] =
      method
      |> Map.get("name")
      |> String.split(".")

    doc = make_doc_for_method(method)

    {module, {name, format_name(name), doc}}
  end

  defp make_doc_for_method(method) do
    [
      Map.get(method, "description", "No description provided"),
      parse_parameters(method)
    ]
    |> Enum.join("\n\n")
  end

  defp parse_parameters(method) do
    method
    |> Map.get("parameters", [])
    |> Enum.map(&format_parameter/1)
    |> Enum.join("\n")
  end

  defp format_parameter(p) do
    "- **#{p["name"]}** (#{p["type"]}) – *#{p["description"]}*"
  end

  defp group(enum) do
    Enum.group_by(
      enum,
      fn {module, _} ->
        module
      end,
      fn {_, value} ->
        Macro.escape(value)
      end
    )
  end
end
