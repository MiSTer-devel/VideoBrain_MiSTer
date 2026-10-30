-- Run with MAME's vidbrain driver and MUSIC_OCTAVE_OUT set to an output prefix.
local machine = manager.machine
local cpu = machine.devices[":maincpu"]
local space = cpu.spaces["program"]
local prefix = assert(os.getenv("MUSIC_OCTAVE_OUT"))
local log = assert(io.open(prefix .. ".csv", "w"))
log:write("seconds,event,background\n")
local taps = {}
for address, name in pairs({[0x1154] = "bank", [0x10f8] = "note", [0x41c8] = "video"}) do
    taps[#taps + 1] = space:install_read_tap(address, address, name, function(offset, data)
        log:write(string.format("%.9f,%s,%02x\n", machine.time:as_double(), name,
            space:read_u8(0x08f5)))
    end)
end
local keys = {{33, 140, 150}, {33, 200, 210}}
local frame, cursor = 0, 270
for _, fields in ipairs({2, 1}) do
    for cycle = 1, 6 do
        for _, bank in ipairs({33, 19, 22}) do
            keys[#keys + 1] = {bank, cursor, cursor + fields}
            cursor = cursor + 2 * fields
            keys[#keys + 1] = {34, cursor, cursor + 2}
            cursor = cursor + 4
        end
    end
end
keys[#keys + 1] = {33, cursor, cursor + 20}
keys[#keys + 1] = {34, cursor + 22, cursor + 30}
music_octave_frame = emu.add_machine_frame_notifier(function()
    frame = frame + 1
    local down = {}
    for _, key in ipairs(keys) do
        if frame >= key[2] and frame < key[3] then down[key[1]] = true end
    end
    for _, key in ipairs({33, 19, 22, 34}) do
        local column, row = key // 4, key % 4
        local port = column == 8 and ":UV201-31" or string.format(":IO%02d", column)
        machine.ioport.ports[port]:field(1 << row):set_value(
            down[key] and 1 or 0)
    end
    if frame == cursor + 40 then
        machine.screens[":screen"]:snapshot(prefix .. ".png")
    end
end)
music_octave_stop = emu.add_machine_stop_notifier(function()
    log:close()
    print(string.format("OCTAVE_CHECK: %d taps", #taps))
end)
