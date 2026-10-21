local focus_mult = 1.0 +
    0.06 * clamp(recent_attackers - 1, 0, 3) +
    0.20 * persistent_attackers
fast_pressure = focus_mult *
    (0.45 * d075 + 0.35 * d075_2 + 0.20 * d2_4)
slow_pressure = focus_mult *
    (0.15 * d075 + 0.45 * d075_2 + 0.40 * d2_4)

local hot2 = math.max(0, safe(input.hot_healing_2s, 0)) / maximum
local hot4 = math.max(0, safe(input.hot_healing_4s, 0)) / maximum
local projected2 = clamp(ratio - 2.0 * fast_pressure + 0.80 * hot2, 0, 1)
local projected4 = clamp(ratio - 4.0 * slow_pressure + 0.70 * hot4, 0, 1)
local net_pressure = math.max(0.001, slow_pressure - 0.70 * (hot4 / 4.0))
local ttd = ratio / net_pressure
