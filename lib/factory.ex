defmodule Factory do
  defmacro __using__(model: model) do
    quote do
      alias unquote(model)
      import Factory
      require Logger
      @model unquote(model)
      @factories %{}

      def create_pair(type, attrs \\ []) do
        create_list(type, 2, attrs)
      end

      def create_list(type, n, attrs \\ []) when n > 1 do
        1..n |> Enum.map fn (index) ->
          create(type, attrs, index)
        end
      end

      def build_list(type, n, attrs \\ []) when n > 1 do
        1..n |> Enum.map fn (index) ->
          build(type, attrs, index)
        end
      end

      def build(attrs) when is_list(attrs) do
        build(:default, attrs)
      end

      def build(type \\ :default, attrs \\ [], n \\ 1) do
        struct(unquote(model), example(type, n)) |> struct(attrs)
      end

      def create(attrs) when is_list(attrs) do
        create(:default, attrs)
      end

      def create(type \\ :default, attrs \\ [], n \\ 1) do
        build(type, attrs, n) |> Repo.insert!
      end

      @before_compile Factory
    end
  end

  defmacro factory(name, block) do
    quote do
      @factory unquote(name)
      @factories Map.put(@factories, unquote(name), %{})
      unquote(block)
    end
  end

  defmacro field(name, value) do
    value = Macro.escape(value)
    quote do
      factory = Map.put(@factories[@factory], unquote(name), unquote(value))
      @factories Map.put(@factories, @factory, factory)
    end
  end

  defmacro type(name, block) do
    quote do
      default_factory = @factories[:default]
      @factory unquote(name)
      @factories Map.put(@factories, unquote(name), default_factory)
      unquote(block)
    end
  end

  defmacro shorthand(name, type) do
    quote do
      def unquote(:"build_#{name}_params")(keys \\ []), do: build_params(unquote(type), keys)
      def unquote(:"build_#{name}")(attrs \\ []), do: build(unquote(type), attrs)
      def unquote(:"create_#{name}")(attrs \\ []), do: create(unquote(type), attrs)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def example(nil, n), do: example(:default, n)
      def example(name, n) do
        case Map.get(@factories, name) do
          nil ->
            Logger.error "No factory '#{name}' is defined for #{@model}."
            %{}
          attrs ->
            attrs |> Enum.reduce %{}, fn ({k, v}, acc) ->
              {evaluated, _} = Code.eval_quoted v, [n: n]
              Map.put acc, k, evaluated
            end
        end
      end

      def build_params(type \\ :default, keys \\ nil) do
        case keys do
          nil ->
            Map.take(build(type), Map.keys(@factories[type]))
          keys when is_list(keys) ->
            Map.take(build(type), keys)
        end
      end
    end
  end
end
