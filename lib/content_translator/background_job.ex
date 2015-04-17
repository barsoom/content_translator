# First attempt at persistent background jobs in Elixir. Probably not
# how you usually do it in erlang.

# As long as it manages to prevent loss of data during restart it's
# good enough for now.

defmodule ContentTranslator.BackgroundJob do
  use GenServer
  alias ContentTranslator.BackgroundJob.Persistance

  @job_timeout_in_seconds 30

  def start_link do
    state = []
    server = GenServer.start_link(__MODULE__, state, [ name: :background_job ])
    enqueue_previously_enqueued_jobs
    server
  end

  def enqueue(genserver_name, data) do
    add_job(genserver_name, data)
    |> run_job_in_background(genserver_name, data)
  end

  def handle_cast({ caller, [ job_id, genserver_name, data ] }, state) do
    run_job(caller, job_id, genserver_name, data)
    {:noreply, state}
  end

  defp run_job_in_background(job_id, genserver_name, data) do
    GenServer.cast(:background_job, { self, [ job_id, genserver_name, data ] })
  end

  defp run_job(caller, job_id, genserver_name, data) do
    GenServer.cast(genserver_name, { self, data })

    receive do
      :done ->
        mark_job_as_finished(job_id)
      after @job_timeout_in_seconds * 1000 ->
        raise "Job timed out, took longer than #{@job_timeout_in_seconds}. Job: #{genserver_name} #{data}."
    end
  end

  defp add_job(genserver_name, data), do: Persistance.add_job(genserver_name, data)
  defp mark_job_as_finished(job_id), do: Persistance.mark_job_as_finished(job_id)

  defp enqueue_previously_enqueued_jobs do
    Enum.each(Persistance.previously_enqueued_jobs, fn({ job_id, genserver_name, data }) ->
      run_job_in_background(job_id, genserver_name, data)
    end)
  end
end
