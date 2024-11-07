this.fpv_base_skill <- this.inherit("scripts/skills/skill", {
    m = {},
    function create() {
        this.m.Type = this.Const.SkillType.Active;
        this.m.Order = this.Const.SkillOrder.UtilityTargeted;
        this.m.Delay = 0;
        this.m.IsSerialized = false;
        this.m.IsActive = true;
        this.m.IsTargeted = true;
        this.m.IsTargetingActor = false;
        this.m.IsStacking = false;
        this.m.IsAttack = true;
        this.m.IsOffensiveToolSkill = true;
        this.m.IsRanged = false;
        this.m.IsIgnoredAsAOO = true;
        this.m.IsShowingProjectile = true;
        this.m.IsUsingHitchance = false;
        this.m.IsDoingForwardMove = true;
        this.m.ActionPointCost = 6;
        this.m.FatigueCost = 25;
        this.m.MinRange = 3;
        this.m.MaxRange = 10;
        this.m.MaxLevelDifference = 3;
        this.m.ProjectileTimeScale = 1.5;
        this.m.IsProjectileRotated = false;
    }

    function onVerifyTarget( _originTile, _targetTile )
    {
//        if (!this.skill.onVerifyTarget(_originTile, _targetTile))
//        {
//            return false;
//        }
//
//        if (_originTile.Level + 1 < _targetTile.Level)
//        {
//            return false;
//        }

        return true;
    }

    function getAffectedTiles (_targetTile, _user) {
        local ret = [];
        local ownTile = _user.getTile();
        local dir = ownTile.getDirectionTo(_targetTile);
        local forwardTile = null;
        if (_targetTile.hasNextTile(dir)) {
            forwardTile = _targetTile.getNextTile(dir);
            if (this.Math.abs(forwardTile.Level - ownTile.Level) <= this.m.MaxLevelDifference) {
                dir = ownTile.getDirectionTo(forwardTile);
                forwardTile = forwardTile.getNextTile(dir);
                if (this.Math.abs(forwardTile.Level - ownTile.Level) <= this.m.MaxLevelDifference) ret.push(forwardTile);
            }
        }
        for (local i = 0; i != 6; i++) {
            if (forwardTile.hasNextTile(i)) {
                local tile = forwardTile.getNextTile(i);
                ret.push(tile);
            }
        }
        return ret;
    }

    function onTargetSelected( _targetTile ) {
        local affectedTiles = this.getAffectedTiles(_targetTile, this.getContainer().getActor());
        foreach( t in affectedTiles ) {
            this.Tactical.getHighlighter().addOverlayIcon(this.Const.Tactical.Settings.AreaOfEffectIcon, t, t.Pos.X, t.Pos.Y);
        }
    }

    function onAfterUpdate( _properties ) {
        this.m.FatigueCostMult = _properties.IsSpecializedInThrowing ? this.Const.Combat.WeaponSpecFatigueMult : 1.0;
    }

    function onUse( _user, _targetTile )
    {
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

        _user.getItems().unequip(_user.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand));
        this.Time.scheduleEvent(this.TimeUnit.Real, 250, this.onApply.bindenv(this), {
            Skill = this,
            User = _user,
            TargetTiles = this.getAffectedTiles(_targetTile, _user),
        });
    }
});