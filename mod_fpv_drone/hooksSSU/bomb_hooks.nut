local bombs = [
    "fpv_throw_daze_bomb_skill",
    "fpv_throw_fire_bomb_skill",
    "fpv_throw_smoke_bomb_skill",
    "fpv_throw_holy_water_skill",
    "fpv_throw_acid_flask_skill",
    "fpv_throw_acid_flask_02_skill",
]

foreach (b in bombs) {
    ::ModFPVDrone.Hooks.hook("scripts/skills/actives/" + b, function(q) {
        q.onUse = @() function (_user, _targetTile) {
            if (this.m.IsShowingProjectile && this.m.ProjectileType != 0) {
                local flip = !this.m.IsProjectileRotated && _targetTile.Pos.X > _user.getPos().X;

                if (_user.getTile().getDistanceTo(_targetTile) >= this.Const.Combat.SpawnProjectileMinDist) {
                    this.Tactical.spawnProjectileEffect(this.Const.ProjectileSprite[this.m.ProjectileType], _user.getTile(), _targetTile, 1.0, this.m.ProjectileTimeScale, this.m.IsProjectileRotated, flip);
                }
            }
            // falcon removal
            if (this.Math.rand(1,3) != 2 && ::ModFPVDrone.SuicideMode) {
                _user.getItems().unequip(_user.getItems().getItemAtSlot(this.Const.ItemSlot.Accessory));
            }
            // consume ammo instead of unequipping grenade
            _user.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand).consumeAmmo();

            this.Time.scheduleEvent(this.TimeUnit.Real, 250, this.onApply.bindenv(this), {
                Skill = this,
                User = _user,
                TargetTiles = this.getAffectedTiles(_targetTile, _user)
            });
        }

        q.isHidden = @(__original) function () {
            if(__original())
                return true;
            return getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Offhand).getAmmo() == 0;
        }
    });
}
