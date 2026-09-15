local function friendlier(current, maximum, handle, rhs)
    if rhs == nil then
        return true
    end
    local lhs_ratio = current * rhs.maximum
    local rhs_ratio = rhs.current * maximum
    if lhs_ratio ~= rhs_ratio then
        return lhs_ratio < rhs_ratio
    end
    local lhs_missing = maximum - current
    local rhs_missing = rhs.maximum - rhs.current
    if lhs_missing ~= rhs_missing then
        return lhs_missing > rhs_missing
    end
    return handle < rhs.handle
end
