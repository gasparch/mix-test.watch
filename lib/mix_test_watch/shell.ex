defmodule MixTestWatch.Shell do
  @moduledoc """
  Responsible for running of shell commands.
  """

  alias MixTestWatch.Config

  @spec exec(String.t, %Config{}) :: :ok
  @doc """
  Runs a given shell command, steaming the output to STDOUT
  """
  def exec(exe, config) do
    args = ~w(stream binary exit_status use_stdio stderr_to_stdout)a
    {:spawn, exe} |> Port.open(args) |> results_loop(config)
    :ok
  end

  @spec results_loop(port, %Config{}) :: pos_integer
  defp results_loop(port, %Config{stop_on_failed: true}) do
    results_stop_on_failure(port)
  end
  defp results_loop(port, %Config{stop_on_failed: false}) do
    results_loop(port)
  end

  @spec results_loop(port) :: pos_integer
  defp results_loop(port) do
    receive do
      {^port, {:data, data}} ->
          IO.write(data)
          results_loop(port)
      {^port, {:exit_status, status}} ->
        status
    end
  end

  @spec results_stop_on_failure(port) :: pos_integer
  defp results_stop_on_failure(port) do
    receive do
      {^port, {:data, data}} ->
          IO.write(data)
          is_failed = Regex.match?(~R(\n    {1,10}.{1,5}stacktrace:), data)

          if is_failed do
            results_skipping(port)
          else
            results_stop_on_failure(port)
          end
      {^port, {:exit_status, status}} ->
        status
    end
  end

  @spec results_skipping(port) :: pos_integer
  defp results_skipping(port) do
    #Port.close port
    receive do
      {^port, {:data, _data}} ->
        results_skipping(port)
      {^port, {:exit_status, status}} ->
        status
    end
  end

end
