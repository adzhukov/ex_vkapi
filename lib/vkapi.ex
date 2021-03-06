defmodule VKAPI do
  use VKAPI.Macro

  @doc """
  A universal method for calling a sequence of other methods while saving and filtering interim results.
  """
  def execute(code) when is_binary(code) do
    execute([code: code])
  end

  def execute(code) do
    VKAPI.Request.request("execute", code)
  end
end
