-- Auto Grass Battler 3.0.2 for Gen1Recomp 0.2.60 / Mod API 2.

local Bag = require("src.inventory.Bag")
local Damage = require("src.battle.Damage")
local Sound = require("src.core.Sound")
local Stats = require("src.pokemon.Stats")

local SPEEDS = { slow = 0.62, normal = 0.38, fast = 0.24 }
local TEXT_SPEEDS = { safe = 0.22, normal = 0.16, fast = 0.10 }
local RECOIL_OR_RISKY = {
  SELFDESTRUCT = true, EXPLOSION = true, TAKE_DOWN = true,
  DOUBLE_EDGE = true, SUBMISSION = true, STRUGGLE = true,
}
local HM_MOVES = { CUT = true, FLY = true, SURF = true, STRENGTH = true, FLASH = true }
local STATUS_MOVE_VALUE = {
  RECOVER = 95, SOFTBOILED = 95, SLEEP_POWDER = 85, SPORE = 90,
  HYPNOSIS = 72, LOVELY_KISS = 75, THUNDER_WAVE = 72, GLARE = 68,
  SWORDS_DANCE = 82, AMNESIA = 88, AGILITY = 65, GROWTH = 62,
  REFLECT = 55, LIGHT_SCREEN = 55, SUBSTITUTE = 62, LEECH_SEED = 60,
  TOXIC = 64, CONFUSE_RAY = 58, SING = 52, REST = 58,
  SPLASH = 0, TELEPORT = 2, WHIRLWIND = 4, ROAR = 4,
}

return function(mod)
  mod.options:define({
    { key = "captureMode", label = "AUTO CAPTURE", type = "choice",
      default = "unowned", choices = {
        { "OFF", "off" }, { "NOT OWNED", "unowned" },
      } },
    { key = "captureStrategy", label = "CAPTURE METHOD", type = "choice",
      default = "weaken", choices = {
        { "WEAKEN FIRST", "weaken" }, { "THROW NOW", "immediate" },
      }, visible_if = { key = "captureMode", not_equals = "off" } },
    { key = "captureHp", label = "CAPTURE BELOW %", type = "number",
      default = 35, min = 5, max = 90, step = 5,
      visible_if = { key = "captureStrategy", equals = "weaken" } },
    { key = "ballPolicy", label = "BALL CHOICE", type = "choice",
      default = "best", choices = {
        { "BEST CHANCE", "best" }, { "SAVE BEST BALLS", "weakest" },
        { "POKE BALL ONLY", "poke_only" },
      }, visible_if = { key = "captureMode", not_equals = "off" } },
    { key = "stopHp", label = "STOP BELOW HP %", type = "number",
      default = 25, min = 5, max = 75, step = 5 },
    { key = "autoCenter", label = "AUTO CENTER WHEN NO PP", type = "toggle",
      default = true },
    { key = "walkSpeed", label = "WALK SPEED", type = "choice",
      default = "normal", choices = {
        { "SLOW", "slow" }, { "NORMAL", "normal" }, { "FAST", "fast" },
      } },
    { key = "textSpeed", label = "TEXT SPEED", type = "choice",
      default = "normal", choices = {
        { "SAFE", "safe" }, { "NORMAL", "normal" }, { "FAST", "fast" },
      } },
    { key = "toggleKey", label = "TOGGLE KEY", type = "choice",
      default = "f6", choices = {
        { "F6", "f6" }, { "F7", "f7" }, { "F8", "f8" }, { "TAB", "tab" },
      } },
    { key = "gamepadToggle", label = "GAMEPAD BACK TOGGLE", type = "toggle",
      default = false },
    { key = "autoStart", label = "START AUTOMATICALLY", type = "toggle",
      default = true },
    { key = "showHud", label = "SHOW BOT HUD", type = "toggle", default = true },
    { key = "shinySound", label = "SHINY ALERT SOUND", type = "toggle", default = true },
    { key = "stopSpecies", label = "STOP ON SPECIES", type = "text",
      default = "", maxLen = 80 },
  })

  local enabled = false
  local finishingBattle = false
  local captureInProgress = false
  local captureUnavailable = false
  local activeWildBattle = false
  local shinyBattle = false
  local elapsed = 0
  local direction = "left"
  local intentId = 0
  local handledRevision = nil
  local stopReason = "Appuyez sur la touche choisie"
  local sessionSeconds = 0
  local learningStatus = nil
  local recoveryPhase = nil
  local recoveryOrigin = nil
  local recoveryTarget = nil
  local stats = {
    encounters = mod.save:get("encounters", 0),
    wins = mod.save:get("wins", 0),
    captures = mod.save:get("captures", 0),
    shinies = mod.save:get("shinies", 0),
    seconds = mod.save:get("seconds", 0),
  }

  local function option(key, fallback)
    local value = mod.options:get(key)
    if value == nil then return fallback end
    return value
  end

  local function persistStats()
    local wholeSeconds = math.floor(sessionSeconds)
    stats.seconds = stats.seconds + wholeSeconds
    sessionSeconds = sessionSeconds - wholeSeconds
    mod.save:set("encounters", stats.encounters)
    mod.save:set("wins", stats.wins)
    mod.save:set("captures", stats.captures)
    mod.save:set("shinies", stats.shinies)
    mod.save:set("seconds", stats.seconds)
  end

  local function setEnabled(value)
    enabled = value and true or false
    elapsed, handledRevision = 0, nil
    stopReason = enabled and nil or "Pause manuelle"
    if not enabled then
      persistStats()
    end
    mod.log:info("Auto Grass Battler: %s", enabled and "ACTIVE" or "DESACTIVE")
  end

  local function stop(reason, alert)
    enabled = false
    finishingBattle = false
    captureInProgress = false
    recoveryPhase, recoveryOrigin, recoveryTarget = nil, nil, nil
    elapsed, handledRevision = 0, nil
    stopReason = reason
    persistStats()
    if alert and option("shinySound", true) then
      pcall(Sound.play, mod.game.data, "Dex_Page_Added")
    end
    mod.log:warn("Auto Grass Battler arrete: %s", reason)
  end

  local function battleState()
    local game = mod.game
    local states = game and game.stack and game.stack.states or {}
    for index = #states, 1, -1 do
      if states[index].isBattleState then return states[index] end
    end
  end

  local function enemyIsShiny()
    local battle = battleState()
    local enemy = battle and battle.enemy and battle.enemy.mon
    return enemy and Stats.isShiny(enemy.dvs) or false
  end

  local function standingInGrass()
    local position = mod.world:current()
    local overworld = mod.world:overworld()
    local map = overworld and overworld.map
    return not not (position and map and map.isGrassCell
      and map:isGrassCell(position.x, position.y))
  end

  local function fieldStatus()
    local position, positionError = mod.world:current()
    if not position then return "HORS JEU: " .. tostring(positionError or "aucun monde") end
    local _, worldError = mod.world:availableFieldActions()
    if worldError then return "ATTENTE: " .. tostring(worldError) end
    if standingInGrass() then return "HERBE DETECTEE - MARCHE ACTIVE" end
    return "PLACEZ-VOUS DANS LES HAUTES HERBES"
  end

  local function mapHasNurse(def)
    if not def then return false end
    if tostring(def.id or ""):find("POKECENTER", 1, true) then return true end
    for _, object in ipairs(def.objects or {}) do
      if object.sprite == "SPRITE_NURSE" then return true end
    end
    return false
  end

  local function mapNeighbours(game, mapId)
    local def = game.data.maps[mapId] or {}
    local neighbours, seen = {}, {}
    local function add(id)
      if type(id) == "string" and id ~= "LAST_MAP" and game.data.maps[id]
          and not seen[id] then
        seen[id] = true
        neighbours[#neighbours + 1] = id
      end
    end
    for _, warp in ipairs(def.warps or {}) do add(warp.destMap) end
    for _, connection in pairs(def.connections or {}) do add(connection.map) end
    return neighbours
  end

  local function nearestCenter(game, startMap)
    local queue, head, seen = { startMap }, 1, { [startMap] = true }
    while head <= #queue do
      local mapId = queue[head]
      head = head + 1
      if mapHasNurse(game.data.maps[mapId]) then return mapId end
      for _, neighbour in ipairs(mapNeighbours(game, mapId)) do
        if not seen[neighbour] then
          seen[neighbour] = true
          queue[#queue + 1] = neighbour
        end
      end
    end
    local saved = game.save and game.save.lastHeal
    return saved and saved.map or nil
  end

  local function partyFullyRestored(game)
    for _, mon in ipairs((game.save and game.save.party) or {}) do
      if not mon.stats or mon.hp < mon.stats.hp or mon.status ~= nil then return false end
      for _, known in ipairs(mon.moves or {}) do
        local def = game.data.moves[known.id]
        local base = def and def.pp or 0
        local maximum = base + (known.ppUps or 0) * math.floor(base / 5)
        if (known.pp or 0) < maximum then return false end
      end
    end
    return true
  end

  local function beginCenterRecovery(game)
    local position = mod.world:current()
    if not position then return stop("Centre inaccessible") end
    recoveryOrigin = {
      mapId = position.mapId, x = position.x, y = position.y,
      facing = position.facing or "down",
    }
    recoveryTarget = nearestCenter(game, position.mapId)
    if not recoveryTarget then return stop("Aucun Centre Pokemon trouve") end
    local ok = mod.world:warpTo(recoveryTarget, 3, 3, "up")
    if not ok then return stop("Impossible de rejoindre le Centre") end
    recoveryPhase = "healing"
    stopReason = "SOIN AU CENTRE: " .. tostring(recoveryTarget)
    elapsed = 0
  end

  local function updateCenterRecovery(game, worldError)
    if recoveryPhase == "travel_pending" then
      if worldError == nil then beginCenterRecovery(game) end
      return true
    end
    if recoveryPhase ~= "healing" and recoveryPhase ~= "returning" then
      return false
    end
    if recoveryPhase == "healing" then
      if partyFullyRestored(game) and worldError == nil then
        local origin = recoveryOrigin
        if not origin then return stop("Point de retour perdu") end
        local ok = mod.world:warpTo(origin.mapId, origin.x, origin.y, origin.facing)
        if not ok then return stop("Retour aux herbes impossible") end
        recoveryPhase = "returning"
        stopReason = "RETOUR AUX HERBES"
        elapsed = 0
      elseif elapsed >= TEXT_SPEEDS[option("textSpeed", "normal")] then
        -- A la case (3,3), A parle a l'infirmiere puis valide HEAL et les textes.
        mod.input:tap(game, "a")
        elapsed = 0
      end
      return true
    end
    if recoveryPhase == "returning" and worldError == nil then
      recoveryPhase, recoveryOrigin, recoveryTarget = nil, nil, nil
      stopReason = nil
      elapsed = 0
    end
    return true
  end

  local function speciesListed(species)
    local wanted = tostring(option("stopSpecies", "")):upper()
    species = tostring(species or ""):upper()
    for entry in wanted:gmatch("[^,;]+") do
      local clean = entry:match("^%s*(.-)%s*$"):gsub("[%s%-]", "_")
      if clean ~= "" and clean == species then return true end
    end
    return false
  end

  local function wantsCapture(snapshot)
    if not (snapshot and snapshot.kind == "wild" and snapshot.catchable) then return false end
    if captureUnavailable then return false end
    local mode = option("captureMode", "unowned")
    if mode == "off" then return false end
    local dex = mod.game.save and mod.game.save.pokedex or {}
    return not (dex.owned and dex.owned[snapshot.enemy.species])
  end

  local function submit(snapshot, intent)
    intentId = intentId + 1
    intent.id, intent.revision = intentId, snapshot.revision
    local ok = mod.battle:submit(intent)
    if ok then handledRevision = snapshot.revision end
    return ok
  end

  local function moveDamage(snapshotMove, maximum)
    local battle = battleState()
    local current = battle and battle.player and battle.player.curMoves
      and battle.player.curMoves[snapshotMove.slot]
    local move = current and battle.data.moves[current.id]
    if not (battle and move and (move.power or 0) > 0) then return nil end
    if RECOIL_OR_RISKY[current.id] then return nil end
    local record = battle.effectRecord and battle:effectRecord(move.effect)
    if record and record.chooseDamage then return nil end
    local randomValue = maximum and battle.ruleset.randMax
      or math.floor((battle.ruleset.randMin + battle.ruleset.randMax) / 2)
    local damage = Damage.compute(battle.ruleset, battle.player, battle.enemy, move, {
      forceCrit = maximum and true or false,
      rng = function() return randomValue end,
    })
    if not damage then return nil end
    if maximum and (move.multiHit or (record and record.hitCount)) then damage = damage * 5 end
    return damage
  end

  local function bestAttack(snapshot, mustNotKo)
    local bestSlot, bestScore = nil, -1
    for _, move in ipairs(snapshot.moves or {}) do
      if (move.pp or 0) > 0 and not move.disabled and (move.effectiveness or 10) > 0 then
        local damage = moveDamage(move, mustNotKo)
        if damage and (not mustNotKo or damage < snapshot.enemy.hp) then
          local accuracy = (move.hitChance or move.accuracy or 100) / 100
          local score = mustNotKo and damage or damage * accuracy
          if score > bestScore then bestSlot, bestScore = move.slot, score end
        end
      end
    end
    return bestSlot
  end

  local function speciesHasType(game, mon, moveType)
    local def = game.data.pokemon[mon.species] or {}
    for _, pokemonType in ipairs(def.types or {}) do
      if pokemonType == moveType then return true end
    end
    return false
  end

  -- Valeur generale hors combat : puissance, precision, PP, STAB et utilite.
  -- Les CS ne sont jamais oubliees, conformement aux regles de la Gen 1.
  local function learnedMoveValue(game, mon, moveId)
    if HM_MOVES[moveId] then return 100000 end
    local move = game.data.moves[moveId]
    if not move then return -1 end
    local accuracy = math.max(1, tonumber(move.accuracy) or 100) / 100
    local power = tonumber(move.power) or 0
    if power > 0 then
      local stab = speciesHasType(game, mon, move.type) and 1.25 or 1
      local value = power * accuracy * stab + math.min(tonumber(move.pp) or 0, 40) * 0.20
      if RECOIL_OR_RISKY[moveId] then value = value * 0.65 end
      return value
    end
    return (STATUS_MOVE_VALUE[moveId] or 24) * accuracy
  end

  local function findMoveLearnScreen(game)
    local states = game and game.stack and game.stack.states or {}
    for index = #states, 1, -1 do
      local state = states[index]
      if state and state.screenId == "MoveLearnMenu" then return state end
    end
  end

  local function moveLearnPlan(game, menu)
    local newValue = learnedMoveValue(game, menu.mon, menu.newMoveId)
    local worstSlot, worstValue = nil, math.huge
    for slot, known in ipairs(menu.mon.moves or {}) do
      local value = learnedMoveValue(game, menu.mon, known.id)
      if value < worstValue then worstSlot, worstValue = slot, value end
    end
    if worstSlot and newValue > worstValue then
      return worstSlot, newValue, worstValue
    end
    return nil, newValue, worstValue
  end

  local function automateMoveLearning(game)
    local menu = findMoveLearnScreen(game)
    if not menu then return false end
    local slot = moveLearnPlan(game, menu)
    if not menu.selecting then
      -- Avance le texte puis choisit OUI pour afficher la liste des attaques.
      mod.input:tap(game, "a")
    elseif slot then
      local forgotten = menu.mon.moves[slot] and menu.mon.moves[slot].id or "?"
      menu.index = slot
      learningStatus = "APPREND " .. tostring(menu.newMoveId)
        .. " / OUBLIE " .. tostring(forgotten)
      mod.input:tap(game, "a")
    else
      learningStatus = "GARDE LES 4 ATTAQUES / REFUSE " .. tostring(menu.newMoveId)
      mod.input:tap(game, "b")
    end
    return true
  end

  local function selectBall(snapshot)
    local policy = option("ballPolicy", "best")
    local balls = {}
    for _, item in ipairs(snapshot.items or {}) do
      if item.ball and item.count > 0
          and (policy ~= "poke_only" or item.id == "POKE_BALL") then
        balls[#balls + 1] = item
      end
    end
    table.sort(balls, function(a, b)
      local ac, bc = a.catchChance or 0, b.catchChance or 0
      if ac == bc then return a.id < b.id end
      return policy == "weakest" and ac < bc or ac > bc
    end)
    return balls[1]
  end

  local function throwBall(snapshot)
    local ball = selectBall(snapshot)
    if not ball then
      captureUnavailable = true
      captureInProgress = false
      stopReason = "AUCUNE BALL - COMBAT NORMAL"
      mod.log:warn("Auto capture ignoree: aucune Ball autorisee")
      return false
    end
    local battle = battleState()
    if not (battle and battle.phase == "menu") then return false end
    if ((mod.game.save.inventory or {})[ball.id] or 0) <= 0 then
      captureUnavailable = true
      captureInProgress = false
      stopReason = "BALL INDISPONIBLE - COMBAT NORMAL"
      mod.log:warn("Auto capture ignoree: Ball indisponible")
      return false
    end
    Bag.remove(mod.game.save, ball.id, 1)
    captureInProgress = true
    battle.phase = "messages"
    battle.afterQueue = "menu"
    battle:throwBall(ball.id)
    handledRevision = snapshot.revision
    elapsed = 0
    return true
  end

  local function handleBattle(game, snapshot)
    if snapshot.kind ~= "wild" then return stop("Combat non sauvage") end
    if enemyIsShiny() then
      if not shinyBattle then stats.shinies = stats.shinies + 1 end
      shinyBattle = true
      return stop("SHINY DETECTE !", true)
    end
    if speciesListed(snapshot.enemy and snapshot.enemy.species) then
      return stop("Pokemon recherche: " .. tostring(snapshot.enemy.name), true)
    end
    local noPp = #(snapshot.moves or {}) > 0
    for _, move in ipairs(snapshot.moves or {}) do
      if (move.pp or 0) > 0 and not move.disabled then noPp = false break end
    end
    if recoveryPhase == nil and noPp and option("autoCenter", true) then
      recoveryPhase = "fleeing"
      stopReason = "PP EPUISES - FUITE"
    end
    local player = snapshot.player
    if player and (player.maxHp or 0) > 0
        and player.hp * 100 / player.maxHp <= option("stopHp", 25) then
      if option("autoCenter", true) then
        recoveryPhase = "fleeing"
        stopReason = "PV FAIBLES - FUITE ET SOIN"
      else
        return stop("PV faibles")
      end
    end

    if recoveryPhase == "fleeing" then
      if snapshot.prompt == "menu" then
        submit(snapshot, { kind = "menu", choice = "run" })
      elseif snapshot.prompt == "moves" then
        submit(snapshot, { kind = "back" })
      elseif (snapshot.prompt == "advance" or snapshot.prompt == "locked")
          and elapsed >= TEXT_SPEEDS[option("textSpeed", "normal")] then
        mod.input:tap(game, "a")
        elapsed = 0
      end
      return
    end

    if snapshot.prompt == "locked" then
      if elapsed >= TEXT_SPEEDS[option("textSpeed", "normal")] then
        if not automateMoveLearning(game) then mod.input:tap(game, "a") end
        elapsed = 0
      end
      return
    end
    if snapshot.prompt == "advance" or snapshot.prompt == "party" then
      if elapsed >= TEXT_SPEEDS[option("textSpeed", "normal")] then
        mod.input:tap(game, "a")
        elapsed = 0
      end
      return
    end
    if handledRevision == snapshot.revision then return end

    local capture = wantsCapture(snapshot)
    if snapshot.prompt == "menu" and capture then
      local immediate = option("captureStrategy", "weaken") == "immediate"
      local lowEnough = snapshot.enemy.hp * 100 / math.max(1, snapshot.enemy.maxHp)
        <= option("captureHp", 35)
      if immediate or lowEnough then
        if throwBall(snapshot) then return end
        capture = false
      end
      if capture then
        local safeSlot = bestAttack(snapshot, true)
        if safeSlot then
          submit(snapshot, { kind = "menu", choice = "fight" })
        elseif throwBall(snapshot) then
          return
        else
          capture = false
        end
      end
      if not capture then
        submit(snapshot, { kind = "menu", choice = "fight" })
      end
    elseif snapshot.prompt == "menu" then
      submit(snapshot, { kind = "menu", choice = "fight" })
    elseif snapshot.prompt == "moves" then
      local slot = bestAttack(snapshot, capture)
      if not slot then
        if capture then
          submit(snapshot, { kind = "back" })
        elseif option("autoCenter", true) then
          recoveryPhase = "fleeing"
          stopReason = "PP EPUISES - FUITE"
          submit(snapshot, { kind = "back" })
        else
          stop("Plus d'attaque utilisable")
        end
      else
        submit(snapshot, { kind = "move", slot = slot })
      end
    elseif snapshot.prompt == "mimic" then
      submit(snapshot, { kind = "mimic", index = 1 })
    elseif snapshot.prompt == "safari" then
      submit(snapshot, { kind = "safari", action = "ball" })
    end
  end

  mod.hooks:wrap("catch.nickname", function(next, mon, context)
    if captureInProgress then return false end
    return next(mon, context)
  end)

  mod.hooks:wrap("input.key", function(next, game, event)
    local toggleKey = option("toggleKey", "f6")
    if event.phase == "pressed"
        and (event.key == toggleKey or event.key == "f6" or event.key == "tab") then
      setEnabled(not enabled)
      return true
    end
    return next(game, event)
  end)

  mod.hooks:wrap("input.gamepad", function(next, game, event)
    if option("gamepadToggle", false) and event.phase == "pressed"
        and event.button == "back" then
      setEnabled(not enabled)
      return true
    end
    return next(game, event)
  end)

  mod.events:on("battle.started", function(event)
    activeWildBattle = enabled and event and event.kind == "wild"
    captureInProgress, captureUnavailable, shinyBattle = false, false, false
    if activeWildBattle then
      stats.encounters = stats.encounters + 1
      local battle = event.battle
      local enemy = battle and battle.enemy and battle.enemy.mon
      if enemy and Stats.isShiny(enemy.dvs) then
        shinyBattle = true
        stats.shinies = stats.shinies + 1
        stop("SHINY DETECTE !", true)
      end
    end
  end)

  mod.events:on("pokemon.caught", function()
    if captureInProgress then
      stats.captures = stats.captures + 1
      persistStats()
    end
  end)

  mod.events:on("battle.ended", function(event)
    if activeWildBattle and event and event.result == "win" then
      stats.wins = stats.wins + 1
    end
    activeWildBattle, shinyBattle, captureInProgress = false, false, false
    learningStatus = nil
    if recoveryPhase == "fleeing" then
      recoveryPhase = "travel_pending"
      stopReason = "RECHERCHE DU CENTRE LE PLUS PROCHE"
    end
    persistStats()
    if enabled then finishingBattle, elapsed = true, 999 end
  end)

  mod.hooks:wrap("input.step", function(next, game, dt)
    if enabled then sessionSeconds = sessionSeconds + (dt or 0) end
    elapsed = elapsed + (dt or 0)
    if not enabled then return next(game, dt) end

    local snapshot = mod.battle:snapshot()
    if snapshot then
      handleBattle(game, snapshot)
      return next(game, dt)
    end

    handledRevision = nil
    local _, worldError = mod.world:availableFieldActions()
    if updateCenterRecovery(game, worldError) then return next(game, dt) end
    if finishingBattle then
      if worldError == nil then
        finishingBattle, elapsed = false, 0
      elseif elapsed >= TEXT_SPEEDS[option("textSpeed", "normal")] then
        mod.input:tap(game, "a")
        elapsed = 0
      end
      return next(game, dt)
    end

    local walkDelay = SPEEDS[option("walkSpeed", "normal")] or SPEEDS.normal
    if elapsed >= walkDelay and worldError == nil then
      local overworld = mod.world:overworld()
      local player = overworld and overworld.player
      if player and not player.moving and not player.inputLocked then
        local result = player:tryMove(direction, overworld.map, overworld.entities)
        if result == "moved" then
          if overworld.stopSurfingOntoLand then overworld:stopSurfingOntoLand() end
          direction = direction == "left" and "right" or "left"
        elseif result == "blocked" then
          -- Si un cote est bloque, essayer l'autre au prochain passage.
          direction = direction == "left" and "right" or "left"
        end
      end
      elapsed = 0
    end
    return next(game, dt)
  end)

  mod.hooks:wrap("render.hud", function(next, game, viewport)
    local result = next(game, viewport)
    if option("showHud", true) == false or not (love and love.graphics) then return result end
    local g = love.graphics
    g.push("all")
    g.setColor(0.03, 0.05, 0.08, 0.90)
    g.rectangle("fill", 10, 10, 355, 97, 7, 7)
    if stopReason == "SHINY DETECTE !" then g.setColor(1, 0.82, 0.05, 1)
    elseif enabled then g.setColor(0.25, 1, 0.45, 1)
    else g.setColor(1, 0.35, 0.25, 1) end
    g.print(enabled and "BOT ACTIF" or "BOT EN PAUSE", 20, 17)
    g.setColor(1, 1, 1, 0.92)
    g.print(stopReason or "F6 ou TAB pour mettre en pause", 20, 34)
    g.print(("Rencontres %d  Victoires %d  Captures %d  Shinies %d")
      :format(stats.encounters, stats.wins, stats.captures, stats.shinies), 20, 51)
    local total = stats.seconds + math.floor(sessionSeconds)
    g.print(("Temps actif %02d:%02d  Capture: %s")
      :format(math.floor(total / 60), total % 60,
        tostring(option("captureMode", "unowned")):upper()), 20, 68)
    g.setColor(0.65, 0.85, 1, 1)
    g.print(learningStatus or fieldStatus(), 20, 85)
    g.pop()
    return result
  end)

  setEnabled(option("autoStart", true))
end
