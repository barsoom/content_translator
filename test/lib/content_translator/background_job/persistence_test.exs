defmodule ContentTranslator.BackgroundJob.PersistanceTest do
  use ExUnit.Case

  alias ContentTranslator.BackgroundJob.Persistance

  test "adding, listing and marking jobs as finished" do
    # as we rely on exact numbers here, let's clean out redis
    Process.whereis(:redis) |> Exredis.query([ "FLUSHDB" ])

    Persistance.add_job(:server_name, :data1)
    job_id2 = Persistance.add_job(:server_name, :data2)

    assert job_id2 == 2

    assert Persistance.previously_enqueued_jobs == [
      { 1, :server_name, :data1 },
      { 2, :server_name, :data2 },
    ]

    Persistance.mark_job_as_finished(2)

    assert Persistance.previously_enqueued_jobs == [
      { 1, :server_name, :data1 },
    ]
  end
end
