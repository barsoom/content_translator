defmodule TranslationServiceTest do
  use ExUnit.Case
  alias ContentTranslator.FakeTranslationApi
  alias ContentTranslator.TranslationService

  setup do
    FakeTranslationApi.reset
    :ok
  end

  test "creating a new translation" do
    TranslationService.update(self, %{ identifier: "foo", name: "field", value: "value", locale: "en" })

    assert FakeTranslationApi.texts == [
      %{ key: "foo: field", value: "value", locale: "en", id: 1 }
    ]
  end
end
