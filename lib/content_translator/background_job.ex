# First attempt at persistent background jobs in Elixir. Probably not
# how you usually do it in erlang.

# As long as it manages to prevent loss of data during restart it's
# good enough for now.

defmodule ContentTranslator.BackgroundJob do
  use GenServer

  @job_timeout_in_seconds 30

  # todo:
  # - save in redis in web process
  # - fork off ("cast" to BackgroundJob)
  #   - GenServer.cast(server_name, { self, data })
  #   - wait for response
  #   - remove from redis
  #   - send response to client

  def start_link do
    state = []
    server = GenServer.start_link(__MODULE__, state, [ name: :background_job ])
    run_previously_enqueued_jobs
    server
  end

  def enqueue(genserver_name, data) do
    add_job(genserver_name, data)
    run_job_in_background(genserver_name, data)
  end

  def handle_cast({ caller, [ genserver_name, data ] }, state) do
    run_job(caller, genserver_name, data)
    {:noreply, state}
  end

  defp run_job_in_background(genserver_name, data) do
    GenServer.cast(:background_job, { self, [ genserver_name, data ] })
  end

  defp run_job(caller, genserver_name, data) do
    GenServer.cast(genserver_name, { self, data })

    receive do
      message ->
        send caller, message
      after @job_timeout_in_seconds * 1000 ->
        raise "Job timed out, took longer than #{@job_timeout_in_seconds}"
    end

    mark_job_as_finished(genserver_name, data)
  end

  defp add_job(genserver_name, data) do
    # TODO: add to redis
  end

  defp mark_job_as_finished(genserver_name, data) do
    # TODO: remove from redis
  end

  defp run_previously_enqueued_jobs do
    IO.inspect "TODO: Run previously enqueued jobs"
    # read from redis
    # for each: run_job_in_background
  end
end
