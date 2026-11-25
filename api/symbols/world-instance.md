# world:instance

Read prepared local instance classification, optional phase identity and difficulty.

## Signature

```text
world:instance()
```

## Contract and usage

### `world:instance()`

Reads the prepared local player's instance context. It performs no new game
query. Acquire a fresh world inside the current callback; an expired world
raises `stale_world`.

```text
{
  status = "pending" | "ready" | "unavailable",
  revision = integer | nil,
  sampled_ms = integer | nil,
  kind = "flashpoint" | "arena" | "warzone" | "other" | "none" | nil,
  handle = "phase:..." | nil,
  difficulty = string | nil
}
```

`kind`, `handle`, and `difficulty` are available only for a ready observation.
The classification gives arena precedence over warzone, then flashpoint. A
King of the Hill context is classified as `warzone`. A known phase without one
of those classifications is `other`; `other` does not identify an Operation.
`none` is the ready observation of no active phase, not an unavailable result.

The optional handle identifies a phase, and cannot be passed to `world:resolve`
as a unit handle. Difficulty preserves an observed client name such as
`phsFlashpointDifficultyNormal`, `phsFlashpointDifficultyHard`,
`phsFlashpointDifficultySolo`, `phsFlashpointDifficultyOnlySolo`,
`phsFlashpointDifficultyMaster`, or `phsFlashpointDifficultyNone`; omitted means
unavailable, not a guessed difficulty.

`revision` tracks changes to the captured local level/instance context.
`sampled_ms` is the prepared player-stat sampling timestamp in monotonic
milliseconds. Both may be present on a pending/unavailable observation, and
neither makes the missing classification ready. Without a matching prepared
local-player snapshot the result contains only `status = "unavailable"`.

```lua
gos.on_tick(function()
  local world = gos.world()
  local instance = world:instance()
  if instance.status ~= "ready" then return end
  if instance.kind == "flashpoint" then
    -- Use the observed context; difficulty may still be nil.
  end
end)
```

## Related documentation

[Full world and units contract](../world.md)
