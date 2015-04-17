defmodule ContentTranslator.BackgroundJob.Persistance do
  use Exredis.Api

  def add_job(genserver_name, data) do
    job_id = redis |> incr(:last_job_id)

    redis
    |> hset(:jobs, job_id, :erlang.term_to_binary(%{ genserver_name: genserver_name, data: data }))

    job_id
  end

  def mark_job_as_finished(job_id) do
    redis
    |> hdel(:jobs, job_id)
  end

  def previously_enqueued_jobs do
    redis
    |> hgetall(:jobs)
    |> Enum.map fn({ key, data }) ->
      { number, _ } = Integer.parse(key)
      job = :erlang.binary_to_term(data)
      { number, job.genserver_name, job.data }
    end
  end

  defp redis do
    Process.whereis(:redis)
  end
end
