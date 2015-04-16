defmodule ContentTranslatorTest do
  use ExUnit.Case

  test "restarts ContentTranslator.TranslationService when it crashes" do
    old_pid = Process.whereis(:translation_service)

    assert old_pid |> is_pid

    Process.exit old_pid, :kill

    :timer.sleep 1 # Wait for process to restart

    new_pid = Process.whereis(:translation_service)

    assert new_pid |> is_pid
    assert old_pid != new_pid
  end

  test "restarts ContentTranslator.ClientApp when it crashes" do
    old_pid = Process.whereis(:client_app)

    assert old_pid |> is_pid

    Process.exit old_pid, :kill

    :timer.sleep 1 # Wait for process to restart

    new_pid = Process.whereis(:client_app)

    assert new_pid |> is_pid
    assert old_pid != new_pid
  end
end
