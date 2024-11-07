::ModFPVDrone <- {
    ID = "mod_fpv_drone",
    Name = "Falcons with grenades",
    Version = "0.2.0",
    SuicideMode = true,
    MoreFalcons = false,
    // other mods compat
    hasSSU = false,
}
local mod = ::Hooks.register(::ModFPVDrone.ID, ::ModFPVDrone.Version, ::ModFPVDrone.Name);
::ModFPVDrone.Hooks <- mod;

mod.require("mod_msu >= 1.2.6", "mod_modern_hooks >= 0.4.0", "mod_legends >= 18.2.0");

mod.queue(">mod_msu", ">mod_modern_hooks", ">mod_legends", ">mod_sellswords", function() {
    ::ModFPVDrone.Mod <- ::MSU.Class.Mod(::ModFPVDrone.ID, ::ModFPVDrone.Version, ::ModFPVDrone.Name);
    ::ModFPVDrone.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/chopeks/mod_fpv_drone");
    ::ModFPVDrone.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

    local page = ::ModFPVDrone.Mod.ModSettings.addPage("General");
    local settingFalconMode = page.addEnumSetting(
        "FalconMode",
        "Suicide attack",
        ["Suicide attack", "Drop grenade"],
        "Falcon mode",
        "Suicide attack - using the skill will sacrifice falcon on attack, with small chance for it to survive. This mod is balanced around this setting.\n\nDrop grenade - alternative mode, that makes falcon drop grenades instead of diving. To balance it a bit, there's chance it will miss and land on adjacent tile."
    );
    settingFalconMode.addCallback(function(_value) {
        ::ModFPVDrone.SuicideMode = _value == "Suicide attack";
    });

//    local settingMoreFalcons = page.addBooleanSetting(
//        "MoreFalcons",
//        false,
//        "More falcons in kennels",
//        "To compensate making the falcons consumable item, there will be higher chance for them to appear in kennels."
//    );
//    settingMoreFalcons.addCallback(function(_value) {
//        ::ModFPVDrone.MoreFalcons = _value;
//    });

    foreach (file in ::IO.enumerateFiles("mod_fpv_drone/hooks/")) {
        ::include(file);
    }

    ::ModFPVDrone.hasSSU = ::mods_getRegisteredMod("mod_sellswords") != null;
    if (::ModFPVDrone.hasSSU) {
        foreach (file in ::IO.enumerateFiles("mod_fpv_drone/hooksSSU/"))
            ::include(file);
    }
});
