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

    local CABINET_TEST_MASK = (1 << 10)
    local CABINET_SERVICE_MASK = (1 << 0)
    local CABINET_COIN_MASK = (1 << 0)

    local STAGE_P1_UP_MASK = (1 << 10)
    local STAGE_P1_DOWN_MASK = (1 << 11)
    local STAGE_P1_LEFT_MASK = (1 << 8)
    local STAGE_P1_RIGHT_MASK = (1 << 9)

    local STAGE_P2_UP_MASK = (1 << 2)
    local STAGE_P2_DOWN_MASK = (1 << 3)
    local STAGE_P2_LEFT_MASK = (1 << 0)
    local STAGE_P2_RIGHT_MASK = (1 << 1)

    local CABINET_P1_LEFT_MASK = (1 << 13)
    local CABINET_P1_RIGHT_MASK = (1 << 14)
    local CABINET_P1_START_MASK = (1 << 15)

    local CABINET_P2_LEFT_MASK = (1 << 5)
    local CABINET_P2_RIGHT_MASK = (1 << 6) 
    local CABINET_P2_START_MASK = (1 << 7)

    local DDRIO_TEST_MASK = (1 << 4)
    local DDRIO_COIN_MASK = (1 << 5)
    local DDRIO_SERVICE_MASK = (1 << 6)

    local DDRIO_P1_UP_MASK = (1 << 17)
    local DDRIO_P1_DOWN_MASK = (1 << 18)
    local DDRIO_P1_LEFT_MASK = (1 << 19)
    local DDRIO_P1_RIGHT_MASK = (1 << 20)

    local DDRIO_P2_UP_MASK = (1 << 9)
    local DDRIO_P2_DOWN_MASK = (1 << 10)
    local DDRIO_P2_LEFT_MASK = (1 << 11)
    local DDRIO_P2_RIGHT_MASK = (1 << 12)

    local DDRIO_P1_START_MASK = (1 << 16)
    local DDRIO_P1_MENU_LEFT_MASK = (1 << 22)
    local DDRIO_P1_MENU_RIGHT_MASK = (1 << 23)

    local DDRIO_P2_START_MASK = (1 << 8)
    local DDRIO_P2_MENU_LEFT_MASK = (1 << 14)
    local DDRIO_P2_MENU_RIGHT_MASK = (1 << 15)

    local ddrio_state_pad = 0
    local ddrio_state_p3io_light = 0
    local ddrio_state_extio_light = 0

    local function ksys573_jamma1_read(offset, data, mask)
        -- print(string.format("ksys573_jamma1_read %x %x %x", offset, data, mask))

        return
    end

    local function ksys573_jamma2_read(offset, data, mask)
        if offset == 0x1f400008 and mask == 0xffff then
            local data_stage = 0
            local data_button = 0

            if ddrio_state_pad & DDRIO_P1_UP_MASK > 0 then
                data_stage = data_stage | STAGE_P1_UP_MASK
            end

            if ddrio_state_pad & DDRIO_P1_DOWN_MASK > 0 then
                data_stage = data_stage | STAGE_P1_DOWN_MASK
            end

            if ddrio_state_pad & DDRIO_P1_LEFT_MASK > 0 then
                data_stage = data_stage | STAGE_P1_LEFT_MASK
            end

            if ddrio_state_pad & DDRIO_P1_RIGHT_MASK > 0 then
                data_stage = data_stage | STAGE_P1_RIGHT_MASK
            end

            if ddrio_state_pad & DDRIO_P2_UP_MASK > 0 then
                data_stage = data_stage | STAGE_P2_UP_MASK
            end

            if ddrio_state_pad & DDRIO_P2_DOWN_MASK > 0 then
                data_stage = data_stage | STAGE_P2_DOWN_MASK
            end

            if ddrio_state_pad & DDRIO_P2_LEFT_MASK > 0 then
                data_stage = data_stage | STAGE_P2_LEFT_MASK
            end

            if ddrio_state_pad & DDRIO_P2_RIGHT_MASK > 0 then
                data_stage = data_stage | STAGE_P2_RIGHT_MASK
            end

            if ddrio_state_pad & DDRIO_P1_START_MASK > 0 then
                data_button = data_button | CABINET_P1_START_MASK
            end

            if ddrio_state_pad & DDRIO_P1_MENU_LEFT_MASK > 0 then
                data_button = data_button | CABINET_P1_LEFT_MASK
            end

            if ddrio_state_pad & DDRIO_P1_MENU_RIGHT_MASK > 0 then
                data_button = data_button | CABINET_P1_RIGHT_MASK
            end

            if ddrio_state_pad & DDRIO_P2_START_MASK > 0 then
                data_button = data_button | CABINET_P2_START_MASK
            end

            if ddrio_state_pad & DDRIO_P2_MENU_LEFT_MASK > 0 then
                data_button = data_button | CABINET_P2_LEFT_MASK
            end

            if ddrio_state_pad & DDRIO_P2_MENU_RIGHT_MASK > 0 then
                data_button = data_button | CABINET_P2_RIGHT_MASK
            end

            -- TODO apply stage mask here based on what the digital IO reports regarding which
            -- sensor group is selected

            -- Inputs are active low, invert
            data_stage = (data_stage & 0x0f0f) ~ 0x0f0f;
            data_button = (data_button & 0xf0f0) ~ 0xf0f0;

            return (data_stage | data_button) & mask
        end

        return
    end

    local function ksys573_jamma3_read(offset, data, mask)
        if offset == 0x1f40000c and mask == 0xffff then
            local data_button = 0

            if ddrio_state_pad & DDRIO_TEST_MASK > 0 then
                data_button = data_button | CABINET_TEST_MASK
            end

            -- Input is active low
            data = data | data_button

            -- TODO continue here, test button not working, yet

            print(string.format(">> %x %x", data, data_button))

            return data
        end

        return
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
        -- TODO
        ddr_io_set_lights_extio(0)
        ddr_io_set_lights_p3io(0)

        -- TODO
        ddrio_state_p3io_light = 0
        ddrio_state_extio_light = 0

        -- Next frame inputs
        ddrio_state_pad = ddr_io_read_pad()

        return
    end

    local function init()
        -- Protect to init once because register_start is also called on machine reset
        if is_initialized then
            return
        end

        -- Heuristic to ensure this plugin only runs with ddr or ds (dancing stage) games
        -- This also blocks the plugin from running when mame is started in "UI mode"
        -- TODO
        -- if (not string.find(manager.machine.system.name, "ddr")) or (not string.find(manager.machine.system.name, "ds")) then
        --     return
        -- end

        local memory = manager.machine.devices[":maincpu"].spaces["program"]


        -- map(0x1f400000, 0x1f400003).portr("IN0").portw("OUT0");
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

        -- Tap into relevant IO regions for dispatching data reads and writes to those data areas
        -- Key reference for callback functions registered here:
        -- https://github.com/mamedev/mame/blob/9dbf099b651c8c48140db01059614e23d5bbdcb9/src/mame/konami/ksys573.cpp

        -- Leave out 0x1f400000 to 0x1f400003 which is jamma0 which are not used
        -- memory:install_read_tap(0x1f400004, 0x1f400007, "ksys573_jamma1_read", ksys573_jamma1_read)
        -- TODO assign return value and do the if-then-else foo, see iidxio
        memory:install_read_tap(0x1f400008, 0x1f40000b, "ksys573_jamma2_read", ksys573_jamma2_read)
        memory:install_read_tap(0x1f40000c, 0x1f40000f, "ksys573_jamma3_read", ksys573_jamma3_read)


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

        if ddr_io_init() == false then
            manager.machine:logerror("ERROR initializing ddrio backend")
            return
        end

        -- Switch everything off and read inputs once to avoid random (input) noise
        ddr_io_set_lights_extio(0)
        ddr_io_set_lights_p3io(0)
        ddr_io_set_lights_hdxs_panel(0)

        for i = 0, 0x0b, 1 do
            ddr_io_set_lights_hdxs_rgb(i, 0, 0, 0)
        end

        is_initialized = true

        frame_update()

        manager.machine:logerror("ddrio plugin initialized")
    end

    local function deinit()
        if not is_initialized then
            return
        end

        -- Switch everything off
        ddr_io_set_lights_extio(0)
        ddr_io_set_lights_p3io(0)
        ddr_io_set_lights_hdxs_panel(0)

        for i = 0, 0x0b, 1 do
            ddr_io_set_lights_hdxs_rgb(i, 0, 0, 0)
        end

        frame_update()

        ddrio_fini()

        is_initialized = false

        manager.machine:logerror("ddrio plugin de-initialized")
    end

    ---------------------------------------------------------------------------
    -- Main
    ---------------------------------------------------------------------------

    emu.register_start(init)
    emu.register_stop(deinit)
    emu.register_frame(frame_update)
end

return exports