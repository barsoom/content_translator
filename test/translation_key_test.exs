defmodule TranslationKeyTest do
  use ExUnit.Case

  test "generating a key" do
    assert TranslationKey.build("campaign_5", "title") == "campaign_5: title"
  end

  test "parsing a key" do
    key = TranslationKey.build("campaign_5", "title")
    assert TranslationKey.parse(key) == [ "campaign_5", "title" ]
  end
end
