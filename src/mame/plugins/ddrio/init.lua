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



    local ksys573_jamma1_state = 0
    local ksys573_jamma2_state = 0
    local ksys573_jamma3_state = 0

    -- TODO later (tm)
    -- local io_state_hdxs_light = 0
    -- local io_state_hdxs_rgb_light = 0

    local function ksys573_jamma1_read(offset, data, mask)
        print(string.format("ksys573_jamma1_read %x %x %x", offset, data, mask))

        return data
    end

    local function ksys573_jamma2_read(offset, data, mask)
        print(string.format("ksys573_jamma2_read %x %x %x", offset, data, mask))

        return data
    end

    local function ksys573_jamma3_read(offset, data, mask)
        print(string.format("ksys573_jamma3_read %x %x %x", offset, data, mask))

        return data
    end

    local function ksys573_pad_read(offset, data, mask)
       



        -- u32 ddrio_stage;
        -- u32 ddrio_button;
    
        -- ddrio_stage = 0;
        -- ddrio_button = 0;
    
        -- ddrio_driver_read_inputs(&ddrio_stage, &ddrio_button);
    
        -- u32 stage = (m_ddr_stage_joystick->read() & 0x0f0f) ^ 0x0f0f;
        -- u32 button = (m_ddr_buttons_joystick->read() & 0xf0f0) ^ 0xf0f0;
    
        -- u32 stage_merged = ddrio_stage | stage;
        -- u32 button_merged = ddrio_button | button;
    
        -- stage_merged = stage_merged ^ 0x0f0f;
        -- button_merged = button_merged ^ 0xf0f0;
    
        -- stage_merged &= m_stage_mask;
    
        -- return stage_merged | button_merged;


        -- PORT_BIT( 0x00000100, IP_ACTIVE_LOW, IPT_JOYSTICK_LEFT ) PORT_8WAY PORT_PLAYER( 1 )
        -- PORT_BIT( 0x00000200, IP_ACTIVE_LOW, IPT_JOYSTICK_RIGHT ) PORT_8WAY PORT_PLAYER( 1 )
        -- PORT_BIT( 0x00000400, IP_ACTIVE_LOW, IPT_JOYSTICK_UP ) PORT_8WAY PORT_PLAYER( 1 )
        -- PORT_BIT( 0x00000800, IP_ACTIVE_LOW, IPT_JOYSTICK_DOWN ) PORT_8WAY PORT_PLAYER( 1 )
        -- PORT_BIT( 0x00001000, IP_ACTIVE_LOW, IPT_BUTTON1 ) PORT_PLAYER( 1 ) /* skip init? */
        -- PORT_BIT( 0x00002000, IP_ACTIVE_LOW, IPT_BUTTON2 ) PORT_PLAYER( 1 )
        -- PORT_BIT( 0x00004000, IP_ACTIVE_LOW, IPT_BUTTON3 ) PORT_PLAYER( 1 )
        -- PORT_BIT( 0x00008000, IP_ACTIVE_LOW, IPT_START1 ) /* skip init? */
        -- PORT_BIT( 0x00000001, IP_ACTIVE_LOW, IPT_JOYSTICK_LEFT ) PORT_8WAY PORT_PLAYER( 2 )
        -- PORT_BIT( 0x00000002, IP_ACTIVE_LOW, IPT_JOYSTICK_RIGHT ) PORT_8WAY PORT_PLAYER( 2 )
        -- PORT_BIT( 0x00000004, IP_ACTIVE_LOW, IPT_JOYSTICK_UP ) PORT_8WAY PORT_PLAYER( 2 )
        -- PORT_BIT( 0x00000008, IP_ACTIVE_LOW, IPT_JOYSTICK_DOWN ) PORT_8WAY PORT_PLAYER( 2 )
        -- PORT_BIT( 0x00000010, IP_ACTIVE_LOW, IPT_BUTTON1 ) PORT_PLAYER( 2 ) /* skip init? */
        -- PORT_BIT( 0x00000020, IP_ACTIVE_LOW, IPT_BUTTON2 ) PORT_PLAYER( 2 )
        -- PORT_BIT( 0x00000040, IP_ACTIVE_LOW, IPT_BUTTON3 ) PORT_PLAYER( 2 )
        -- PORT_BIT( 0x00000080, IP_ACTIVE_LOW, IPT_START2 ) /* skip init? */
    end

    local function ksys573_sys_test_read(offset, data, mask)
        -- PORT_MODIFY( "IN3" )
        -- PORT_BIT( 0x00000400, IP_ACTIVE_LOW, IPT_CUSTOM ) PORT_READ_LINE_MEMBER( ksys573_state, ddrio_inputs_sys_test_read )

    --     const struct ddrio_driver::input_state* input_state = m_ddrio_driver.input_state_front();

	-- bool test = (m_ddr_sys_joystick->read() & 0x02) ^ 0x02;

	-- bool merged = input_state->cabinet_operator.test || test;

	-- return merged ? 1 : 0;
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
        -- ddr_io_lua_set_lights_extio(0)
        -- ddr_io_lua_set_lights_p3io(0)

        -- Next frame inputs
        -- local pad = ddr_io_lua_read_pad()

    



    -- enum ddr_pad_bit {
    --     DDR_TEST = 0x04,
    --     DDR_COIN = 0x05,
    --     DDR_SERVICE = 0x06,
    
    --     DDR_P2_START = 0x08,
    --     DDR_P2_UP = 0x09,
    --     DDR_P2_DOWN = 0x0A,
    --     DDR_P2_LEFT = 0x0B,
    --     DDR_P2_RIGHT = 0x0C,
    --     DDR_P2_MENU_LEFT = 0x0E,
    --     DDR_P2_MENU_RIGHT = 0x0F,
    --     DDR_P2_MENU_UP = 0x02,
    --     DDR_P2_MENU_DOWN = 0x03,
    
    --     DDR_P1_START = 0x10,
    --     DDR_P1_UP = 0x11,
    --     DDR_P1_DOWN = 0x12,
    --     DDR_P1_LEFT = 0x13,
    --     DDR_P1_RIGHT = 0x14,
    --     DDR_P1_MENU_LEFT = 0x16,
    --     DDR_P1_MENU_RIGHT = 0x17,
    --     DDR_P1_MENU_UP = 0x00,
    --     DDR_P1_MENU_DOWN = 0x01,
    -- };
    local ddrio_state_pad = 0

    -- enum p3io_light_bit {
    --     LIGHT_P1_MENU = 0x00,
    --     LIGHT_P2_MENU = 0x01,
    --     LIGHT_P2_LOWER_LAMP = 0x04,
    --     LIGHT_P2_UPPER_LAMP = 0x05,
    --     LIGHT_P1_LOWER_LAMP = 0x06,
    --     LIGHT_P1_UPPER_LAMP = 0x07,
    -- };
    local ddrio_state_p3io_light = 0

    -- enum extio_light_bit {
    --     LIGHT_NEONS = 0x0E,
    
    --     LIGHT_P2_RIGHT = 0x13,
    --     LIGHT_P2_LEFT = 0x14,
    --     LIGHT_P2_DOWN = 0x15,
    --     LIGHT_P2_UP = 0x16,
    
    --     LIGHT_P1_RIGHT = 0x1B,
    --     LIGHT_P1_LEFT = 0x1C,
    --     LIGHT_P1_DOWN = 0x1D,
    --     LIGHT_P1_UP = 0x1E
    -- };
    local ddrio_state_extio_light = 0

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

        -- Tap into relevant IO regions for dispatching data reads and writes to those data areas
        -- Key reference for callback functions registered here:
        -- https://github.com/mamedev/mame/blob/9dbf099b651c8c48140db01059614e23d5bbdcb9/src/mame/konami/twinkle.cpp
        -- callback_twinkle_io_write = memory:install_write_tap(0x1f220000, 0x1f220003, "twinkle_io_write", twinkle_io_write)
        -- callback_twinkle_io_read = memory:install_read_tap(0x1f220004, 0x1f220007, "twinkle_io_read", twinkle_io_read)
        -- callback_twinkle_keys_read = memory:install_read_tap(0x1f240000, 0x1f240003, "twinkle_keys_read", twinkle_keys_read)
        -- callback_twinkle_keys_write = memory:install_write_tap(0x1f250000, 0x1f250003, "twinkle_keys_write", twinkle_keys_write)

        print("installed hooks")

        -- Leave out 0x1f400000 to 0x1f400003 which is jamma0 which are not used
        -- memory:install_read_tap(0x1f400004, 0x1f400007, "ksys573_jamma1_read", ksys573_jamma1_read)
        memory:install_read_tap(0x1f400008, 0x1f40000b, "ksys573_jamma2_read", ksys573_jamma2_read)
        -- memory:install_read_tap(0x1f40000c, 0x1f40000f, "ksys573_jamma3_read", ksys573_jamma3_read)


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
        -- require("ddrio_lua_bind")

        -- if ddr_io_lua_init() == false then
        --     manager.machine:logerror("ERROR initializing ddrio backend")
        --     return
        -- end

        -- Switch everything off and read inputs once to avoid random (input) noise
        -- ddr_io_lua_set_lights_extio(0)
        -- ddr_io_lua_set_lights_p3io(0)
        -- ddr_io_lua_set_lights_hdxs_panel(0)

        -- for i = 0, 0x0b, 1 do
        --     ddr_io_lua_set_lights_hdxs_rgb(i, 0, 0, 0)
        -- end

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

    print(">>> ddrio plugin")

    emu.register_start(init)
    emu.register_stop(deinit)
    emu.register_frame(frame_update)
end

return exports