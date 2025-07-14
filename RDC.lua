--[[
    RDC (Roblox Decompiler Core)
    Advanced introspection-based decompiler for Roblox exploit environments
    Compatible with Synapse X, Script-Ware, and similar executors
    
    Features:
    - Complete function analysis with debug.getproto recursion
    - Script instance decompilation via getsenv/require
    - Deep nested closure support (unlimited depth)
    - Full metadata extraction without truncation
    - Structured table output (no printing)
    - Superior visibility compared to Medal
]]

local RDC = {}

-- Internal utilities
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    return success and result or nil
end

local function getValueType(value)
    local valueType = type(value)
    if valueType == "function" then
        local info = safeCall(debug.getinfo, value, "S")
        return info and info.what or "function"
    elseif valueType == "userdata" then
        local mt = getmetatable(value)
        if mt and mt.__type then
            return mt.__type
        end
        return "userdata"
    end
    return valueType
end

local function deepCopyValue(value)
    local valueType = type(value)
    
    if valueType == "table" then
        local copy = {}
        for k, v in pairs(value) do
            copy[k] = v -- Shallow copy for tables to avoid infinite recursion
        end
        return copy
    elseif valueType == "function" then
        return {
            __type = "function",
            __address = tostring(value):match("0x%x+") or "unknown",
            __info = safeCall(debug.getinfo, value, "nSlu") or {}
        }
    elseif valueType == "userdata" then
        return {
            __type = "userdata",
            __class = getValueType(value),
            __address = tostring(value):match("0x%x+") or "unknown"
        }
    elseif valueType == "thread" then
        return {
            __type = "thread",
            __status = coroutine.status(value),
            __address = tostring(value):match("0x%x+") or "unknown"
        }
    else
        return value
    end
end

-- Core function analysis
local function extractConstants(func)
    local constants = {}
    local constantsRaw = safeCall(debug.getconstants, func)
    
    if not constantsRaw then
        return constants
    end
    
    for i, constant in ipairs(constantsRaw) do
        constants[i] = {
            index = i,
            value = deepCopyValue(constant),
            type = getValueType(constant),
            raw = constant
        }
    end
    
    return constants
end

local function extractUpvalues(func)
    local upvalues = {}
    local i = 1
    
    while true do
        local name, value = safeCall(debug.getupvalue, func, i)
        if not name then break end
        
        upvalues[name] = {
            index = i,
            name = name,
            value = deepCopyValue(value),
            type = getValueType(value),
            raw = value
        }
        
        i = i + 1
    end
    
    return upvalues
end

local function extractMetadata(func)
    local info = safeCall(debug.getinfo, func, "nSluf")
    if not info then
        return {
            name = "<unknown>",
            source = "<unknown>",
            short_src = "<unknown>",
            linedefined = 0,
            lastlinedefined = 0,
            what = "unknown",
            numparams = 0,
            is_vararg = false,
            numupvalues = 0,
            func_address = tostring(func):match("0x%x+") or "unknown"
        }
    end
    
    return {
        name = info.name or "<anonymous>",
        source = info.source or "<unknown>",
        short_src = info.short_src or "<unknown>",
        linedefined = info.linedefined or 0,
        lastlinedefined = info.lastlinedefined or 0,
        what = info.what or "Lua",
        numparams = info.nparams or 0,
        is_vararg = info.isvararg or false,
        numupvalues = info.nups or 0,
        func_address = tostring(func):match("0x%x+") or "unknown",
        activelines = info.activelines or {}
    }
end

local function extractProtos(func)
    local protos = {}
    local i = 1
    
    while true do
        local proto = safeCall(debug.getproto, func, i)
        if not proto then break end
        
        protos[i] = proto
        i = i + 1
    end
    
    return protos
end

-- Recursive function dumping
local function dumpFunctionRecursive(func, depth, visited)
    depth = depth or 0
    visited = visited or {}
    
    -- Prevent infinite recursion
    local funcAddress = tostring(func)
    if visited[funcAddress] then
        return {
            __type = "function_reference",
            __address = funcAddress,
            __circular = true,
            __depth = depth
        }
    end
    visited[funcAddress] = true
    
    local dump = {
        __type = "function_dump",
        __depth = depth,
        __address = funcAddress,
        metadata = extractMetadata(func),
        constants = extractConstants(func),
        upvalues = extractUpvalues(func),
        subprotos = {}
    }
    
    -- Extract and recursively dump sub-prototypes
    local protos = extractProtos(func)
    for i, proto in pairs(protos) do
        dump.subprotos[i] = dumpFunctionRecursive(proto, depth + 1, visited)
    end
    
    -- Remove from visited to allow the same function in different branches
    visited[funcAddress] = nil
    
    return dump
end

-- Main API functions
function RDC.dump(func)
    if type(func) ~= "function" then
        error("RDC.dump expects a function as argument, got " .. type(func))
    end
    
    return dumpFunctionRecursive(func, 0, {})
end

function RDC.dumpScript(instance)
    if not instance or not instance.ClassName then
        error("RDC.dumpScript expects a Script, LocalScript, or ModuleScript instance")
    end
    
    local className = instance.ClassName
    local validTypes = {
        ["Script"] = true,
        ["LocalScript"] = true,
        ["ModuleScript"] = true
    }
    
    if not validTypes[className] then
        error("RDC.dumpScript expects a Script, LocalScript, or ModuleScript, got " .. className)
    end
    
    local scriptDump = {
        __type = "script_dump",
        __instance = {
            name = instance.Name,
            className = className,
            fullName = instance:GetFullName(),
            source_size = #(instance.Source or ""),
            parent = instance.Parent and instance.Parent.Name or "nil"
        },
        functions = {},
        environment = {},
        errors = {}
    }
    
    -- Attempt to get script environment
    local env = nil
    local mainFunc = nil
    
    if className == "ModuleScript" then
        -- For ModuleScripts, try to require them
        local success, result = pcall(require, instance)
        if success then
            if type(result) == "function" then
                mainFunc = result
            elseif type(result) == "table" then
                -- Scan table for functions
                for key, value in pairs(result) do
                    if type(value) == "function" then
                        scriptDump.functions[key] = RDC.dump(value)
                    end
                end
            end
        else
            table.insert(scriptDump.errors, "Failed to require ModuleScript: " .. tostring(result))
        end
    else
        -- For Scripts and LocalScripts, try to get environment
        if getsenv then
            env = safeCall(getsenv, instance)
        elseif getfenv then
            env = safeCall(getfenv, instance)
        end
        
        if env then
            -- Extract environment details
            for key, value in pairs(env) do
                if type(value) == "function" and key ~= "_G" and key ~= "shared" then
                    scriptDump.functions[key] = RDC.dump(value)
                elseif type(value) ~= "function" then
                    scriptDump.environment[key] = {
                        type = getValueType(value),
                        value = deepCopyValue(value)
                    }
                end
            end
        else
            table.insert(scriptDump.errors, "Failed to get script environment")
        end
    end
    
    -- If we found a main function, dump it
    if mainFunc then
        scriptDump.functions["__main"] = RDC.dump(mainFunc)
    end
    
    -- Try to extract functions from garbage collector if available
    if getgc then
        local gcFunctions = {}
        local gc = getgc(true)
        
        for i, obj in ipairs(gc) do
            if type(obj) == "function" then
                local info = safeCall(debug.getinfo, obj, "S")
                if info and info.source and info.source:find(instance.Name) then
                    local funcName = "gc_function_" .. i
                    gcFunctions[funcName] = RDC.dump(obj)
                end
            end
        end
        
        if next(gcFunctions) then
            scriptDump.gc_functions = gcFunctions
        end
    end
    
    return scriptDump
end

-- Utility functions for advanced analysis
function RDC.findFunctionsByName(name)
    if not getgc then
        error("getgc function not available in this environment")
    end
    
    local results = {}
    local gc = getgc(true)
    
    for i, obj in ipairs(gc) do
        if type(obj) == "function" then
            local info = safeCall(debug.getinfo, obj, "n")
            if info and info.name == name then
                table.insert(results, {
                    func = obj,
                    dump = RDC.dump(obj),
                    gc_index = i
                })
            end
        end
    end
    
    return results
end

function RDC.findFunctionsBySource(sourcePattern)
    if not getgc then
        error("getgc function not available in this environment")
    end
    
    local results = {}
    local gc = getgc(true)
    
    for i, obj in ipairs(gc) do
        if type(obj) == "function" then
            local info = safeCall(debug.getinfo, obj, "S")
            if info and info.source and info.source:match(sourcePattern) then
                table.insert(results, {
                    func = obj,
                    dump = RDC.dump(obj),
                    gc_index = i,
                    source = info.source
                })
            end
        end
    end
    
    return results
end

function RDC.analyzeUpvalueChain(func)
    local chain = {}
    local visited = {}
    
    local function walkUpvalues(f, depth)
        depth = depth or 0
        local funcAddr = tostring(f)
        
        if visited[funcAddr] or depth > 100 then
            return
        end
        visited[funcAddr] = true
        
        local upvalues = extractUpvalues(f)
        for name, upvalue in pairs(upvalues) do
            if type(upvalue.raw) == "function" then
                chain[name] = {
                    depth = depth,
                    func = upvalue.raw,
                    dump = RDC.dump(upvalue.raw)
                }
                walkUpvalues(upvalue.raw, depth + 1)
            end
        end
    end
    
    walkUpvalues(func)
    return chain
end

-- Statistics and analysis
function RDC.getStats(dump)
    local stats = {
        total_functions = 0,
        total_constants = 0,
        total_upvalues = 0,
        max_depth = 0,
        function_types = {},
        source_files = {}
    }
    
    local function walkDump(d, depth)
        depth = depth or 0
        stats.max_depth = math.max(stats.max_depth, depth)
        
        if d.__type == "function_dump" then
            stats.total_functions = stats.total_functions + 1
            stats.total_constants = stats.total_constants + #d.constants
            
            local upvalueCount = 0
            for _ in pairs(d.upvalues) do
                upvalueCount = upvalueCount + 1
            end
            stats.total_upvalues = stats.total_upvalues + upvalueCount
            
            local funcType = d.metadata.what or "unknown"
            stats.function_types[funcType] = (stats.function_types[funcType] or 0) + 1
            
            local source = d.metadata.short_src or "unknown"
            stats.source_files[source] = (stats.source_files[source] or 0) + 1
            
            for _, subdump in pairs(d.subprotos) do
                walkDump(subdump, depth + 1)
            end
        end
    end
    
    walkDump(dump)
    return stats
end

-- Version and metadata
RDC.VERSION = "2.0.0"
RDC.AUTHOR = "RDC Advanced Team"
RDC.COMPATIBLE_EXECUTORS = {"Synapse X", "Script-Ware", "Krnl", "Oxygen U", "Fluxus"}

return RDC
