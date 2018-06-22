defmodule Metex do

  def temperatures_of(cities) do
    coordinator_pid =
      # creates a coordinator process
      spawn(Metex.Coordinator, :loop, [[], Enum.count(cities)])
    # iterate through the cities
    cities |> Enum.each(fn city ->
      # creates a worker process and executes its loop function
      worker_pid = spawn(Metex.Worker, :loop, [])
      # sends the worker a message containing the
      # coordinator process's pid and city
      send worker_pid, {coordinator_pid, city}
    end)
  end

end
