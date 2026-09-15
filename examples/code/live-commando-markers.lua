function Detector:draw_markers(now, options)
    now = finite(now) and now or 0.0
    for serial, marker in pairs(self.markers) do
        if type(marker) ~= "table" or not finite(marker.expiresAt) or marker.expiresAt <= now then
            self.markers[serial] = nil
        elseif type(options) == "table" and options.enabled ~= false and
            gos.overlay and type(gos.overlay.draw_circle) == "function" and
            valid_position(marker.position) then
            local remaining = math.max(0.05, marker.expiresAt - now)
            local color = marker.eventName == "Force Camouflage" and "orange" or "magenta"
            pcall(gos.overlay.draw_circle, "stl_o_" .. tostring(serial), {
                world_space = true, position = marker.position, radius = 0.8,
                color = color, segments = 48, thickness = 3, ttl = remaining,
            })
            pcall(gos.overlay.draw_circle, "stl_i_" .. tostring(serial), {
                world_space = true, position = marker.position, radius = 0.18,
                color = color, segments = 24, thickness = 2.5, ttl = remaining,
            })
        end
    end
end
