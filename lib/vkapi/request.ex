defmodule VKAPI.Request do
  @base_url "https://api.vk.com/method/"
  @default_user_agent 'com.vk.vkclient/108 (unknown, iPhone OS 13.1, iPhone, Scale/2.000000)'
  @default_params [v: 5.78]

  def request(method, user_params) do
    defaults()
    |> Keyword.merge(user_params)
    |> form_url(method)
    |> Kernel.to_charlist()
    |> form_request()
    |> send()
    |> parse_response()
    |> format_json()
  end

  defp defaults do
    @default_params
    |> Keyword.merge([access_token: VKAPI.SessionProvider.access_token()])
  end

  defp format_json(json) do
    case json do
      %{"error" => reason} -> {:error, reason}
      %{"response" => response} -> {:ok, response}
      _ -> {:raw, json}
    end
  end

  defp parse_response({:ok, {_status, _headers, body}}) do
    Jason.decode!(body)
  end

  defp parse_response({:error, {reason}}) do
    IO.inspect(reason)
  end

  defp send(request, method \\ :get) do
    :httpc.request(method, request, [], [])
  end

  defp form_request(url) do
    {url, [{'User-Agent', @default_user_agent}]}
  end

  defp form_url(params, method) do
    @base_url <> method <> "?" <> encode_query(params)
  end

  defp encode_query(query) do
    Enum.map_join(query, "&", &encode_kv/1)
  end

  defp encode_kv({key, value}) do
    Kernel.to_string(key) <> "=" <> encode(value)
  end

  defp encode(value) when is_list(value) do
    value
    |> Enum.join(",")
    |> encode()
  end

  defp encode(value) do
    value
    |> Kernel.to_string()
    |> URI.encode_www_form()
  end
end
