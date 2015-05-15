defmodule ContentTranslator.BackgroundJobTest do
  use ExUnit.Case

  alias ContentTranslator.BackgroundJob

  defmodule FakeService do
    use GenServer

    def start_link do
      state = []
      GenServer.start_link(__MODULE__, state, [ name: :fake_service ])
    end

    def handle_cast({ background_job_runner, new_data }, state) do
      send background_job_runner, :done

      {:noreply, [ new_data | state ]}
    end

    def handle_call(:state, _from, state) do
      {:reply, state, state}
    end
  end

  setup do
    FakeService.start_link
    :ok
  end

  test "can run background jobs" do
    BackgroundJob.enqueue(:fake_service, :data1)
    BackgroundJob.enqueue(:fake_service, :data2)

    wait_for_the_jobs_to_be_run

    assert GenServer.call(:fake_service, :state) == [ :data2, :data1 ]
  end

  # the API call is async, so we need to wait for it to finish
  defp wait_for_the_jobs_to_be_run do
    :timer.sleep 100
  end
end
