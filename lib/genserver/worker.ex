defmodule Metex.GenServer.Worker do
  use GenServer

  @name MW

  ## Client API

  def start_link(opts \\ []) do
    # GenServer.start_link(__MODULE__, :ok, opts)
    # can be called with a process name
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: MW])
  end

  #def get_temperature(pid, location) do
  def get_temperature(location) do
    # name or pid
    # GenServer.call(pid, {:location, location})
    GenServer.call(@name, {:location, location})
  end

  # accessing the server state
  #def get_stats(pid) do
  def get_stats do
    # name or pid
    # GenServer.call(pid, :get_stats)
    GenServer.call(@name, :get_stats)
  end

  #def reset_stats(pid) do
  def reset_stats do
    # name or pid
    # GenServer.cast(pid, :reset_stats)
    GenServer.cast(@name, :reset_stats)
  end

  #def stop(pid) do
  def stop do
    # name or pid
    # GenServer.cast(pid, :stop)
    GenServer.cast(@name, :stop)
  end

  ## Server Callbacks

  @doc """
  Can return:
    {:ok, state}
    {:ok, state, timeout}
    :ignore
    {:stop, reason}
  """
  def init(:ok) do
    {:ok, %{}}
  end

  @doc """
  Can return:
    {:reply, reply, state}
    {:reply, reply, state, timeout}
    {:reply, reply, state, :hibernate}
    {:noreply, state}
    {:noreply, state, timeout}
    {:noreply, state, hibernate}
    {:stop, reason, reply, state}
    {:stop, reason, state}
  Synchronous request
  """
  def handle_call({:location, location}, _from, stats) do
    # makes a request to the API for the location's temperature
    case temperature_of(location) do
      {:ok, temp} ->
        # updates the stats map with the location frequency
        new_stats = update_stats(stats, location)
        # returns a three-element tuple as response
        {:reply, "#{temp}°C", new_stats}
      _ ->
        # returns a three-element tuple that has an :error tag
        {:reply, :error, stats}
    end
  end

  # synchronous request
  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end

  # asynchronous request
  def handle_cast(:reset_stats, _stats) do
    {:noreply, %{}}
  end

  def handle_cast(:stop, stats) do
    {:stop, :normal, stats}
    # will return:
    # 13:06:27.782 [error] GenServer #PID<0.187.0> terminating
    # ** (stop) bad return value: {:stop, :normal, :ok, %{}
    #{:stop, :normal, :ok, stats}
  end

  def handle_info(msg, stats) do
    IO.puts "received #{inspect msg}"
    {:noreply, stats}
  end

  def terminate(reason, stats) do
    # We could write to a file, database etc
    IO.puts "server terminated because of #{inspect reason}"
      inspect stats
    :ok
  end

  ## Helper Functions

  defp temperature_of(location) do
    url_for(location) |> HTTPoison.get |> parse_response
  end

  defp url_for(location) do
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode! |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  def apikey do
    "695b89bcc94703f5cfa124383b97289d"
  end
  defp update_stats(old_stats, location) do
    case Map.has_key?(old_stats, location) do
      true ->
        Map.update!(old_stats, location, &(&1 + 1))
      false ->
        Map.put_new(old_stats, location, 1)
    end
  end

end
