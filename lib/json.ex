# The API this app uses to encode and decode JSON. This way we can have
# the API we like and don't have to call out to the third party dependency
# in more than one place.

defmodule JSON do
  def encode(data) do
    Poison.encode!(data)
  end

  def parse(string) do
    Poison.decode!(string)
  end
end
