defmodule ContentTranslator.BoomWorker do
  use Toniq.Worker

  def perform do
    raise "Boom inside a worker! (checking error reporting)"
  end
end
