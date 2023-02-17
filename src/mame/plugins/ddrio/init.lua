-- This follows the layout of MAME's plugin system, reference for this plugin:
-- https://github.com/mamedev/mame/blob/9dbf099b651c8c48140db01059614e23d5bbdcb9/plugins/autofire/init.lua
local exports = {
	name = 'ddrio',
	version = '0.0.1',
	description = 'Plugin to integrate the Bemanitools 5 ddrio API for IO handling into the ksys573 system',
	license = 'Unlicensed',
	author = { name = 'icex2' }
}

local ddrio = exports

function ddrio.startplugin()
    local is_initialized = false

    local memory = nil

    local cur_io_offset = 0
    local text_16seg = TEXT_16SEG_BLANK

    local function twinkle_io_write(offset, data, mask)
        if offset == 0x1F220000 and mask == 0xFF then
            if cur_io_offset == 0x37 then
                local data_masked = data & mask
                -- Data active low
                local panel_leds = (~data_masked) & 0x0f
                
                iidxio_ep1_set_panel_lights(panel_leds)
            elseif 
                cur_io_offset == 0x3F or
                cur_io_offset == 0x47 or
                cur_io_offset == 0x4f or
                cur_io_offset == 0x57 or
                cur_io_offset == 0x5f or
                cur_io_offset == 0x67 or
                cur_io_offset == 0x6f or
                cur_io_offset == 0x77 or
                    cur_io_offset == 0x7f then
                local data_masked = data & mask
                local char_offset = (cur_io_offset - 0x3f) / 8
                -- The data provided here is already single byte ASCII
                local char = (data_masked ~ 0xff) & 0x7f

                -- Make index start at 1 for lua
                char_offset = char_offset + 1

                -- Handling raw byte data in lua is dumb
                local bytes = {
                    string.byte(text_16seg, 1),
                    string.byte(text_16seg, 2),
                    string.byte(text_16seg, 3),
                    string.byte(text_16seg, 4),
                    string.byte(text_16seg, 5),
                    string.byte(text_16seg, 6),
                    string.byte(text_16seg, 7),
                    string.byte(text_16seg, 8),
                    string.byte(text_16seg, 9),
                }

                bytes[char_offset] = char

                text_16seg = 
                    string.char(
                        bytes[1],
                        bytes[2],
                        bytes[3],
                        bytes[4],
                        bytes[5],
                        bytes[6],
                        bytes[7],
                        bytes[8],
                        bytes[9],
                        -- "Safety" null-terminator
                        0)
            elseif cur_io_offset == 0x87 then
                local data_masked = data & mask
                -- Data active low
                local top_lamp = (~data_masked) & 0xff

                iidxio_ep1_set_top_lamps(top_lamp)
            elseif cur_io_offset == 0x8f then
                local data_masked = data & mask
                -- Data active low
                local neons = (~data_masked) & 0x01

                iidxio_ep1_set_top_neons(neons)
            end
        elseif offset == 0x1F220000 and mask == 0xFF0000 then
            local data_masked = (data & mask) >> 16

            cur_io_offset = data_masked
        end

        return data
    end

    local function twinkle_io_read(offset, data, mask)
        if offset == 0x1f220004 and mask == 0xff then
            local data_masked = data & mask

            if cur_io_offset == 0x07 then
                -- Active low inputs
                data_masked = data_masked ~ 0xff

                local panel = iidxio_ep2_get_panel() & 0x0f
                -- mast test and service, remove coin input
                local sys = iidxio_ep2_get_sys() & 0x03
        
                data_masked = data_masked | panel | (sys << 4)

                return data_masked ~ 0xff
            elseif cur_io_offset == 0x0f then
                local tt_p1 = iidxio_ep2_get_turntable(1) & 0xff

                return tt_p1
            elseif cur_io_offset == 0x17 then
                local tt_p2 = iidxio_ep2_get_turntable(0) & 0xff

                return tt_p2
            elseif cur_io_offset == 0x1f then
                local slider_1 = iidxio_ep2_get_slider(0) & 0x0f
                local slider_2 = iidxio_ep2_get_slider(1) & 0x0f

                return slider_1 | (slider_2 << 4)
            elseif cur_io_offset == 0x27 then
                local slider_3 = iidxio_ep2_get_slider(2) & 0x0f
                local slider_4 = iidxio_ep2_get_slider(3) & 0x0f

                return slider_3 | (slider_4 << 4)
            elseif cur_io_offset == 0x2f then

                local slider_5 = iidxio_ep2_get_slider(4) & 0x0f

                return slider_5
            end
        end

        return data
    end

    local function twinkle_keys_read(offset, data, mask)
        if offset == 0x1f240000 and mask == 0xFFFF then
            local data_masked = data & mask
            -- Active low inputs
            data_masked = data_masked ~ 0xFFFF

            local keys = iidxio_ep2_get_keys() & 0x3fff
            local coin_1 = (iidxio_ep2_get_sys() >> 2) & 0x01

            data_masked = data_masked | keys | (coin_1 << 14)

            return data_masked ~ 0xFFFF
        end

        return data
    end

    local function twinkle_keys_write(offset, data, mask)
        -- words are written using a byte write -_-" 
        -- mask = 0xFF but mask data with 0xFFFF
        if offset == 0x1f250000 and mask == 0xFF then
            local data_masked = data & 0xFFFF
            local keys_leds = data_masked & 0x3fff

            iidxio_ep1_set_deck_lights(keys_leds)
        end

        return data
    end

    -- Drive the IO synchronously to the frame update rate of the game
    -- Note that this is only true if the actual implementation of the iidxio API
    -- used executes actual IO in the calls for ep1, ep2 and ep3
    -- The plugin does not, and by iidxio's API definition, should not reason about
    -- any asynchronous IO in the backend of iidxio
    local function frame_update()
        if not is_initialized then
            return
        end

        -- Previous frame outputs
        if iidxio_ep3_write_16seg(text_16seg) == false then
            manager.machine:logerror("ERROR iidxio_ep3_write_16seg failed")
            return
        end

        if iidxio_ep1_send() == false then
            manager.machine:logerror("ERROR iidxio_ep1_send failed")
            return
        end

        -- Next frame inputs
        if iidxio_ep2_recv() == false then
            manager.machine:logerror("ERROR iidxio_ep2_recv failed")
            return
        end
    end

    local function init()
        -- Protect to init once because register_start is also called on machine reset
        if is_initialized then
            return
        end

        -- Heuristic to ensure this plugin only runs with ddr or ds (dancing stage) games
        -- This also blocks the plugin from running when mame is started in "UI mode"
        if (not string.find(manager.machine.system.name, "ddr")) or (not string.find(manager.machine.system.name, "ds")) then
            return
        end

        local memory = manager.machine.devices[":maincpu"].spaces["program"]

        -- Tap into relevant IO regions for dispatching data reads and writes to those data areas
        -- Key reference for callback functions registered here:
        -- https://github.com/mamedev/mame/blob/9dbf099b651c8c48140db01059614e23d5bbdcb9/src/mame/konami/twinkle.cpp
        -- callback_twinkle_io_write = memory:install_write_tap(0x1f220000, 0x1f220003, "twinkle_io_write", twinkle_io_write)
        -- callback_twinkle_io_read = memory:install_read_tap(0x1f220004, 0x1f220007, "twinkle_io_read", twinkle_io_read)
        -- callback_twinkle_keys_read = memory:install_read_tap(0x1f240000, 0x1f240003, "twinkle_keys_read", twinkle_keys_read)
        -- callback_twinkle_keys_write = memory:install_write_tap(0x1f250000, 0x1f250003, "twinkle_keys_write", twinkle_keys_write)

        memory:install_read_tap(0x1f400004, 0x1f400007, "ksys573_service_coin_read", ksys573_service_coin_read)
        memory:install_read_tap(0x1f400008, 0x1f40000b, "ksys573_pad_read", ksys573_pad_read)
        memory:install_read_tap(0x1f40000c, 0x1f40000f, "ksys573_sys_test_read", ksys573_sys_test_read)


        -- TODO outputs mapped on digital io board

        -- TODO add the base 0x1f640000 to the dio addresses to get the absolute memory address

        -- map(0xe0, 0xe1).w(FUNC(k573dio_device::output_1_w));
        -- map(0xe2, 0xe3).w(FUNC(k573dio_device::output_0_w));
        -- map(0xe4, 0xe5).w(FUNC(k573dio_device::output_3_w));
        -- map(0xe6, 0xe7).w(FUNC(k573dio_device::output_7_w));
        -- map(0xfa, 0xfb).w(FUNC(k573dio_device::output_4_w));
        -- map(0xfc, 0xfd).w(FUNC(k573dio_device::output_5_w));
        -- map(0xfe, 0xff).w(FUNC(k573dio_device::output_2_w));

        -- map(0x1f400004, 0x1f400007).portr("IN1");
        -- map(0x1f400008, 0x1f40000b).portr("IN2");
        -- map(0x1f40000c, 0x1f40000f).portr("IN3");

        -- PORT_MODIFY( "IN1" )
        -- PORT_BIT( 0x10000000, IP_ACTIVE_LOW, IPT_CUSTOM ) PORT_READ_LINE_MEMBER( ksys573_state, ddrio_inputs_sys_service_read )
        -- PORT_BIT( 0x01000000, IP_ACTIVE_LOW, IPT_CUSTOM ) PORT_READ_LINE_MEMBER( ksys573_state, ddrio_inputs_sys_coin1_read )
        -- PORT_BIT( 0x02000000, IP_ACTIVE_LOW, IPT_CUSTOM ) PORT_READ_LINE_MEMBER( ksys573_state, ddrio_inputs_sys_coin2_read )
    
        -- PORT_MODIFY( "IN2" )
        -- PORT_BIT( 0x0000ffff, IP_ACTIVE_HIGH, IPT_CUSTOM ) PORT_CUSTOM_MEMBER( ksys573_state, ddrio_inputs_pad_read )
    
        -- PORT_MODIFY( "IN3" )
        -- PORT_BIT( 0x00000400, IP_ACTIVE_LOW, IPT_CUSTOM ) PORT_READ_LINE_MEMBER( ksys573_state, ddrio_inputs_sys_test_read )

        -- Loads native ddrio lua bindings c-library with ddrio bemanitools API glue code
        require("ddrio_lua_bind")

        if ddr_io_lua_init() == false then
            manager.machine:logerror("ERROR initializing ddrio backend")
            return
        end

        -- Switch everything off and read inputs once to avoid random (input) noise
        ddr_io_lua_set_lights_extio(0)
        ddr_io_lua_set_lights_p3io(0)
        ddr_io_lua_set_lights_hdxs_panel(0)

        for i = 0, 0x0b, 1 do
            ddr_io_lua_set_lights_hdxs_rgb(i, 0, 0, 0)
        end

        is_initialized = true

        frame_update()
    end

    local function deinit()
        if not is_initialized then
            return
        end

        -- Switch everything off
        ddr_io_lua_set_lights_extio(0)
        ddr_io_lua_set_lights_p3io(0)
        ddr_io_lua_set_lights_hdxs_panel(0)

        for i = 0, 0x0b, 1 do
            ddr_io_lua_set_lights_hdxs_rgb(i, 0, 0, 0)
        end

        frame_update()

        ddrio_fini()

        is_initialized = false
    end

    ---------------------------------------------------------------------------
    -- Main
    ---------------------------------------------------------------------------

    emu.register_start(init)
    emu.register_stop(deinit)
    emu.register_frame(frame_update)
end

return exports