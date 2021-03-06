local function expected_amount(product)
  local expected = product.amount
  if not expected then
    expected = (product.amount_min + product.amount_max) / 2.0
  end
  local probability = product.probability or 1

  return expected * probability
end

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if event.destination.valid and event.destination.name ~= "constant-combinator" then
    return
  end
  if event.source.valid and event.source.prototype.type == "assembling-machine" then
    local player_settings = settings.get_player_settings(event.player_index)
    local ingredients_multiplier = player_settings["copy-paste-recipe-signals-ingredient-multiplier"].value
    local products_multiplier = player_settings["copy-paste-recipe-signals-product-multiplier"].value
    local add_ticks = player_settings["copy-paste-recipe-signals-include-ticks"].value
    local add_seconds = player_settings["copy-paste-recipe-signals-include-seconds"].value

    local recipe = event.source.get_recipe()
    if not recipe then return end
    local behavior = event.destination.get_or_create_control_behavior()

    local signals = {}
    if ingredients_multiplier ~= 0 then
      for _, ingredient in pairs(recipe.ingredients) do
        table.insert(signals, {
          signal = {
            type = ingredient.type,
            name = ingredient.name
          },
          count = ingredient.amount * ingredients_multiplier
        })
      end
    end
    if products_multiplier ~= 0 then
      for _, product in pairs(recipe.products) do
        local expected = expected_amount(product)
        table.insert(signals, {
          signal = {
            type = product.type,
            name = product.name
          },
          count = expected * products_multiplier
        })
      end
    end
    if add_ticks then
      table.insert(signals, { signal = { type = "virtual", name = "signal-T" }, count = recipe.energy * 60 })
    end
    if add_seconds then
      table.insert(signals, { signal = { type = "virtual", name = "signal-S" }, count = recipe.energy })
    end

    for index, signal in pairs(signals) do
      if behavior.signals_count >= index then
        behavior.set_signal(index, signal)
      end
    end

    for index = table_size(signals) + 1, behavior.signals_count do
      behavior.set_signal(index, nil)
    end
  end
end)
