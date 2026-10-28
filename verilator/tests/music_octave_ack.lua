-- State-driven octave test. Set MUSIC_OCTAVE_OUT to an output prefix.
local machine = manager.machine
local cpu = machine.devices[":maincpu"]
local space = cpu.spaces["program"]
local prefix = assert(os.getenv("MUSIC_OCTAVE_OUT"))
local log = assert(io.open(prefix .. ".csv", "w"))
log:write("seconds,event,bank,last_key\n")
local frame, deadline, bank, notes = 0, 0, 0, 0
local phase, ready = "startup", false
local overlap = os.getenv("MUSIC_OCTAVE_OVERLAP") == "1"
local due = false
local down, columns, command = {}, 0, 0
local ports = {}
for _, key in ipairs({19, 22, 33, 34}) do
    local column, row = key // 4, key % 4
    local port = column == 8 and ":UV201-31" or string.format(":IO%02d", column)
    ports[key] = machine.ioport.ports[port]:field(1 << row)
end
local function keys(key)
    down = key and {[key] = true} or {}
    for number, field in pairs(ports) do field:set_value(number == key and 1 or 0) end
end
local function record(event)
    log:write(string.format("%.9f,%s,%d,%02x\n", machine.time:as_double(), event,
        bank, space:read_u8(0x0feb)))
end
local function next_bank()
    bank = bank + 1
    keys(({33, 19, 22})[(bank - 1) % 3 + 1])
    phase = "bank"
    record("bank_down")
end
local taps = {}
local io = cpu.spaces["io"]
taps[#taps + 1] = io:install_write_tap(0, 0, "columns", function(offset, data)
    columns = data
end)
taps[#taps + 1] = space:install_write_tap(0x08f7, 0x08f7, "command", function(offset, data)
    command = data
end)
-- Drive matrix rows at the actual IN instruction, avoiding host input frame sampling.
taps[#taps + 1] = io:install_read_tap(1, 1, "rows", function(offset, data)
    local rows = 0
    for key in pairs(down) do
        local column, row = key // 4, key % 4
        if (column < 8 and (columns & (1 << column)) ~= 0)
            or (column == 8 and (command & 16) == 0) then
            rows = rows | (1 << row)
        end
    end
    return (data & 0xf0) | rows
end)
for _, address in ipairs({0x14d8, 0x158f, 0x13b5, 0x1154, 0x10a1, 0x10f8}) do
    taps[#taps + 1] = space:install_read_tap(address, address, "octave_ack", function(offset, data)
        local fast = space:read_u8(0x115d) == 0x97
        if offset == 0x14d8 or offset == 0x158f or (fast and offset == 0x13b5) then
            ready = true
            if phase == "release" then
                record("released")
                if overlap and frame < deadline then
                    phase = "deadline"
                else
                    keys(34)
                    record("note_down")
                    phase = "note"
                end
            elseif overlap and (phase == "gap" or phase == "waiting") and notes < 18 then
                next_bank()
            end
        elseif offset == 0x1154 and phase == "bank" then
            ready = false
            record("accepted")
            keys(nil)
            phase = "release"
        elseif offset == 0x10a1 then
            ready = false
        elseif offset == 0x10f8 and phase == "note" then
            notes = notes + 1
            record("sounding")
            phase, deadline = "hold", frame + 2
        end
    end)
end
taps[#taps + 1] = space:install_write_tap(0x0feb, 0x0feb, "last_key", function(offset, data)
    if phase == "bank" or phase == "release" or phase == "note" then
        log:write(string.format("%.9f,ram_key_%02x,%d,%02x\n", machine.time:as_double(),
            data, bank, data))
    end
end)
music_octave_frame = emu.add_machine_frame_notifier(function()
    frame = frame + 1
    if frame < 270 then
        if (frame >= 140 and frame < 150) or (frame >= 200 and frame < 210) then
            keys(33)
        else
            keys(nil)
        end
    elseif phase == "startup" then
        keys(nil)
        phase = "waiting"
    end
    if phase == "hold" and frame >= deadline then
        keys(nil)
        phase, deadline = "gap", frame + 2
        due = overlap
    elseif phase == "gap" and frame >= deadline then
        phase = "waiting"
    end
    if due and frame >= deadline then record("note_due"); due = false end
    if phase == "deadline" and frame >= deadline then
        keys(34)
        record("note_down")
        phase = "note"
    end
    if phase == "waiting" and ready and notes < 18 then
        next_bank()
    end
end)
music_octave_stop = emu.add_machine_stop_notifier(function()
    record("stop")
    log:close()
    print(string.format("OCTAVE_ACK: %d/18 notes (%d taps)", notes, #taps))
end)
