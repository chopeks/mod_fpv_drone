this.fpv_throw_smoke_bomb_skill <- this.inherit("scripts/skills/actives/fpv_base_skill", {
	m = {},
	function create()
	{
		this.fpv_base_skill.create();
		this.m.ID = "actives.fpv_throw_smoke_bomb";
		this.m.Name = "Falcon Smoke Pot";
		this.m.Description = "Use your falcon to drop a pot filled with substances that upon impact will quickly create a dense cloud.";
		this.m.Icon = "skills/fpv_active_208.png";
		this.m.IconDisabled = "skills/fpv_active_208_sw.png";
		this.m.Overlay = "active_208";
		this.m.SoundOnUse = [
			"sounds/combat/throw_ball_01.wav",
			"sounds/combat/throw_ball_02.wav",
			"sounds/combat/throw_ball_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/dlc6/smoke_bomb_01.wav",
			"sounds/combat/dlc6/smoke_bomb_02.wav",
			"sounds/combat/dlc6/smoke_bomb_03.wav"
		];
		this.m.ProjectileType = this.Const.ProjectileType.Bomb2;
	}

	function getTooltip()
	{
		local ret = this.getDefaultUtilityTooltip();
		ret.push({
			id = 5,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Covers [color=" + this.Const.UI.Color.DamageValue + "]7[/color] tiles in smoke for one round, allowing anyone inside to move freely and ignore zones of control"
		});
		ret.push({
			id = 5,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Increases Ranged Defense by [color=" + this.Const.UI.Color.PositiveValue + "]+100%[/color], but lowers Ranged Skill by [color=" + this.Const.UI.Color.NegativeValue + "]-50%[/color] for anyone inside"
		});
		ret.push({
			id = 6,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Extinguishes existing tile effects like Fire or Miasma"
		});
		return ret;
	}

	function onApply( _data )
	{
		local targets = this.getAffectedTiles(_data.TargetTile);

		this.Sound.play(this.m.SoundOnHit[this.Math.rand(0, this.m.SoundOnHit.len() - 1)], 1.0, _data.TargetTile.Pos);
		local p = {
			Type = "smoke",
			Tooltip = "Dense smoke covers the area, allowing anyone inside to move freely and ignore zones of control, and granting protection from ranged attacks",
			IsPositive = true,
			IsAppliedAtRoundStart = false,
			IsAppliedAtTurnEnd = true,
			IsAppliedOnMovement = false,
			IsAppliedOnEnter = true,
			IsByPlayer = _data.User.isPlayerControlled(),
			Timeout = this.Time.getRound() + 1,
			Callback = this.Const.Tactical.Common.onApplySmoke,
			function Applicable( _a )
			{
				return true;
			}
		};

		foreach( tile in targets )
		{
			if (tile.Properties.Effect != null && tile.Properties.Effect.Type == "smoke")
			{
				tile.Properties.Effect.Timeout = this.Time.getRound() + 1;
			}
			else
			{
				if (tile.Properties.Effect != null)
				{
					this.Tactical.Entities.removeTileEffect(tile);
				}

				tile.Properties.Effect = clone p;
				local particles = [];

				for( local i = 0; i < this.Const.Tactical.SmokeParticles.len(); i = ++i )
				{
					particles.push(this.Tactical.spawnParticleEffect(true, this.Const.Tactical.SmokeParticles[i].Brushes, tile, this.Const.Tactical.SmokeParticles[i].Delay, this.Const.Tactical.SmokeParticles[i].Quantity, this.Const.Tactical.SmokeParticles[i].LifeTimeQuantity, this.Const.Tactical.SmokeParticles[i].SpawnRate, this.Const.Tactical.SmokeParticles[i].Stages));
				}

				this.Tactical.Entities.addTileEffect(tile, tile.Properties.Effect, particles);

				if (tile.IsOccupiedByActor)
				{
					this.Const.Tactical.Common.onApplySmoke(tile, tile.getEntity());
				}
			}
		}
	}

	function isHidden() {
		local offhand = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Offhand);
		if (offhand == null)
			return true;
		return offhand.getID() != "weapon.smoke_bomb";
	}
});

