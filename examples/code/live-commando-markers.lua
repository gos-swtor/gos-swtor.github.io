function Detector:draw_markers(now, options)
    now = finite(now) and now or 0.0
    options = type(options) == "table" and options or {}
    for handle, marker in pairs(self.markers) do
        if not finite(marker.expiresAt) or marker.expiresAt <= now then
            self.markers[handle] = nil
        elseif options.enabled ~= false and valid_position(marker.position) and
            gos.overlay and type(gos.overlay.draw_circle) == "function" then
            local color = marker.eventName == "Force Camouflage" and
                "orange" or "magenta"
            local suffix = tostring(marker.serial)
            for _, ring in ipairs({ { "o", 0.8, 48, 3 }, { "i", 0.18, 24, 2.5 } }) do
                local ok, accepted = pcall(gos.overlay.draw_circle,
                    "stl:" .. ring[1] .. ":" .. suffix, {
                        at = { world = marker.position },
                        world_radius = ring[2],
                        color = color,
                        segments = ring[3],
                        thickness = ring[4],
                        ttl = FRAME_TTL,
                        frame = true,
                    })
                if ok and accepted ~= false then
                    self.stats.markerAccepted = self.stats.markerAccepted + 1
                else
                    self.stats.markerRejected = self.stats.markerRejected + 1
                end
            end
        end
    end
end
