defmodule Repo do
  def insert!(model) do
    model |> Map.put(:id, :random.uniform(1000))
  end
end
