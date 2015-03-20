defmodule TranslationKey do
  def build(identifier, name) do
    "#{identifier}: #{name}"
  end

  def parse(key) do
    String.split(key, ": ")
  end
end
