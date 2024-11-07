this.fpv_throw_daze_bomb_skill <- this.inherit("scripts/skills/skill", {
	m = {},
	function create()
	{
		this.m.ID = "actives.fpv_throw_daze_bomb";
		this.m.Name = "Falcon Fire Pot";
		this.m.Description = "Use your falcon to drop a pot filled with mysterious powders that react violently on impact to create a bright flash and loud bang, and will daze anyone close by - friend and foe alike";
		this.m.Icon = "skills/fpv_active_207.png";
		this.m.IconDisabled = "skills/fpv_active_207_sw.png";
		this.m.Overlay = "active_207";
		this.m.SoundOnUse = [
			"sounds/combat/throw_ball_01.wav",
			"sounds/combat/throw_ball_02.wav",
			"sounds/combat/throw_ball_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/dlc6/daze_bomb_01.wav",
			"sounds/combat/dlc6/daze_bomb_02.wav",
			"sounds/combat/dlc6/daze_bomb_03.wav",
			"sounds/combat/dlc6/daze_bomb_04.wav"
		];
		this.m.SoundOnHitDelay = 0;
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
		this.m.ProjectileType = this.Const.ProjectileType.Bomb2;
		this.m.ProjectileTimeScale = 1.5;
		this.m.IsProjectileRotated = false;
	}

	function getTooltip()
	{
		local ret = this.getDefaultUtilityTooltip();
		ret.push({
			id = 6,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Give up to [color=" + this.Const.UI.Color.DamageValue + "]7[/color] targets the Dazed status effect for 2 turns"
		});
		return ret;
	}


	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile))
		{
			return false;
		}

		if (_originTile.Level + 1 < _targetTile.Level)
		{
			return false;
		}

		return true;
	}

	function onTargetSelected( _targetTile ) {
		local affectedTiles = ::ModFPVDrone.getAffectedTiles(this, _targetTile);
		foreach( t in affectedTiles ) {
			this.Tactical.getHighlighter().addOverlayIcon(this.Const.Tactical.Settings.AreaOfEffectIcon, t, t.Pos.X, t.Pos.Y);
		}
	}


	function onAfterUpdate( _properties )
	{
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
			TargetTile = _targetTile
		});
	}

	function onApply( _data )
	{
		local targets = ::ModFPVDrone.getAffectedTiles(this, _data.TargetTile);

		if (_data.Skill.m.SoundOnHit.len() != 0) {
			this.Sound.play(_data.Skill.m.SoundOnHit[this.Math.rand(0, _data.Skill.m.SoundOnHit.len() - 1)], this.Const.Sound.Volume.Skill, _data.TargetTile.Pos);
		}

		foreach( tile in targets )
		{
			for( local i = 0; i < this.Const.Tactical.DazeParticles.len(); i = ++i )
			{
				this.Tactical.spawnParticleEffect(false, this.Const.Tactical.DazeParticles[i].Brushes, tile, this.Const.Tactical.DazeParticles[i].Delay, this.Const.Tactical.DazeParticles[i].Quantity, this.Const.Tactical.DazeParticles[i].LifeTimeQuantity, this.Const.Tactical.DazeParticles[i].SpawnRate, this.Const.Tactical.DazeParticles[i].Stages);
			}

			if (tile.IsOccupiedByActor && !tile.getEntity().getCurrentProperties().IsImmuneToDaze)
			{
				tile.getEntity().getSkills().add(this.new("scripts/skills/effects/dazed_effect"));
			}
		}
	}

	function isHidden() {
		local offhand = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Offhand);
		if (offhand == null)
			return true;
		return offhand.getID() != "weapon.daze_bomb";
	}
});

