defmodule Factory.Task do
  use Factory, model: Task

  factory :default do
    field :title,       "Buy " <> Faker.Commerce.product_name
    field :description, Faker.Lorem.sentence
    field :notes,       Faker.Lorem.sentences(3) |> Enum.join " "
    field :due_date,    Ecto.Date.local
    field :due_time,    Ecto.Time.local
  end

  type :pending,    { field(:pending, true) }
  type :completed,  { field(:status, "Completed") }
  type :incomplete, { field(:status, "Incomplete") }

  shorthand :pending_task, :pending
end
