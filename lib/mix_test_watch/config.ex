defmodule MixTestWatch.Config do
  @moduledoc """
  Responsible for gathering and packaging the configuration for the task.
  """

  @default_tasks ~w(test)
  @default_prefix "mix"
  @default_clear false
  @default_stop_on_failed false

  defstruct tasks:          @default_tasks,
            prefix:         @default_prefix,
            clear:          @default_clear,
            stop_on_failed: @default_stop_on_failed,
            cli_args:       ""


  @spec new([String.t]) :: %__MODULE__{}
  @doc """
  Create a new config struct, taking values from the ENV
  """
  def new(cli_args \\ []) do
    {stop_on_failed, cli_args} = parse_cli_args(cli_args)
    args = Enum.join(cli_args, " ")
    %__MODULE__{
      tasks:          get_tasks(),
      prefix:         get_prefix(),
      clear:          get_clear(),
      stop_on_failed: stop_on_failed,
      cli_args:       args,
    }
  end

  defp parse_cli_args(cli_args) do
    options = cli_args |> Enum.group_by(& &1 in ["--stop-on-failed", "-s"])
    {Map.has_key?(options, true), options[false] || []}
  end

  defp get_tasks do
    Application.get_env(:mix_test_watch, :tasks, @default_tasks)
  end

  defp get_prefix do
    Application.get_env(:mix_test_watch, :prefix, @default_prefix)
  end

  defp get_clear do
    Application.get_env(:mix_test_watch, :clear, @default_clear)
  end
end
