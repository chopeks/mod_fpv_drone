this.fpv_throw_daze_bomb_skill <- this.inherit("scripts/skills/actives/fpv_base_skill", {
	m = {},
	function create()
	{
		this.fpv_base_skill.create();
		this.m.ID = "actives.fpv_throw_daze_bomb";
		this.m.Name = "Falcon Daze Pot";
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
		this.m.ProjectileType = this.Const.ProjectileType.Bomb2;
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

	function onApply( _data )
	{
		local targets = this.getAffectedTiles(_data.TargetTile);

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

