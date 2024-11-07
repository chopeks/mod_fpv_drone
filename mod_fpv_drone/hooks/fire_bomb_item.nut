::ModFPVDrone.Hooks.hook("scripts/items/accessory/falcon_item", function(q) {
    q.onEquip = @(__original) function() {
        __original();
        this.addSkill(this.new("scripts/skills/actives/fpv_throw_fire_bomb_skill"));
        this.addSkill(this.new("scripts/skills/actives/fpv_throw_smoke_bomb_skill"));
        this.addSkill(this.new("scripts/skills/actives/fpv_throw_daze_bomb_skill"));
    }
});
