defmodule VKAPI.SessionStorage do
  @session_path "~/.vk"

  def get() do
    @session_path
    |> Path.expand()
    |> File.read!()
    |> parse()
  end

  defp parse(content) do
    <<
      user_id::native-integer-size(32),
      expire::native-integer-size(32),
      hash::binary-size(8)-unit(42),
      _::binary-size(8)-unit(22),
      token::binary-size(8)-unit(85),
      _::binary
    >> = content

    {user_id, expire, hash, token}
  end
end

defmodule VKAPI.SessionProvider do
  use Agent

  defp start_link(_initial_value) do
    Agent.start_link(&VKAPI.SessionStorage.get/0, name: __MODULE__)
  end

  def user_id do
    elem(session(), 0)
  end

  def access_token do
    elem(session(), 3)
  end

  def session do
    Agent.get(__MODULE__, & &1)
  end

  def update do
    Agent.update(__MODULE__, fn _state -> VKAPI.SessionStorage.get() end)
  end

  def start(_type, _args) do
    start_link(:ok)
  end
end
