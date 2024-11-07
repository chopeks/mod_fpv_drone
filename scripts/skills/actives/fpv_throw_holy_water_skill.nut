this.fpv_throw_holy_water_skill <- this.inherit("scripts/skills/actives/fpv_base_skill", {
	m = {},
	function create()
	{
		this.fpv_base_skill.create();
		this.m.ID = "actives.fpv_holy_water";
		this.m.Name = "Falcon Holy water";
		this.m.Description = "Use your falcon to drop a flask of blessed water towards a target, where it will shatter and spray its contents. The blessed water will burn the undead, but will not affect other targets.";
		this.m.Icon = "skills/fpv_active_97.png";
		this.m.IconDisabled = "skills/fpv_active_97_sw.png";
		this.m.Overlay = "active_97";
		this.m.SoundOnUse = [
			"sounds/combat/throw_ball_01.wav",
			"sounds/combat/throw_ball_02.wav",
			"sounds/combat/throw_ball_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/acid_flask_impact_01.wav",
			"sounds/combat/acid_flask_impact_02.wav",
			"sounds/combat/acid_flask_impact_03.wav",
			"sounds/combat/acid_flask_impact_04.wav"
		];
		this.m.ProjectileType = this.Const.ProjectileType.Bomb2;
	}

	function getTooltip()
	{
		local ret = this.getDefaultUtilityTooltip();
		ret.push({
			id = 6,
			type = "text",
			icon = "ui/icons/regular_damage.png",
			text = "Inflicts [color=" + this.Const.UI.Color.DamageValue + "]20[/color] damage to hitpoints for [color=" + this.Const.UI.Color.DamageValue + "]3[/color] turns, all of which ignores armor"
		});
		ret.push({
			id = 6,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Has a [color=" + this.Const.UI.Color.DamageValue + "]33%[/color] chance to hit bystanders at the same or lower height level as well."
		});
		ret.push({
			id = 6,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Only affects undead targets"
		});
		return ret;
	}

	function getAffectedTiles (_targetTile, _user) {
		return this.getAffectedTile(_targetTile, _user);
	}

	function applyEffect(_target) {
		if (!_target.getFlags().has("undead")) {
			return;
		}
		local poison = _target.getSkills().getSkillByID("effects.holy_water");
		if (poison == null) {
			_target.getSkills().add(this.new("scripts/skills/effects/holy_water_effect"));
		} else {
			poison.resetTime();
		}
	}

	function onApply( _data ) {
		local targetTile = _data.TargetTiles[0];
		local targetEntity = targetTile.getEntity();

		if (targetEntity != null) {
			if (_data.Skill.m.SoundOnHit.len() != 0) {
				this.Sound.play(_data.Skill.m.SoundOnHit[this.Math.rand(0, _data.Skill.m.SoundOnHit.len() - 1)], this.Const.Sound.Volume.Skill, targetEntity.getPos());
			}

			_data.Skill.applyEffect(targetEntity);
		}

		for( local i = 0; i < 6; i++) {
			if (targetTile.hasNextTile(i)) {
				local nextTile = targetTile.getNextTile(i);

				if (this.Math.rand(1, 3) > 1)
					continue;
				if (nextTile.Level > targetTile.Level)
					continue;
				if (!nextTile.IsOccupiedByActor)
					continue;
				_data.Skill.applyEffect(nextTile.getEntity());
			}
		}
	}

	function isHidden() {
		local offhand = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Offhand);
		if (offhand == null)
			return true;
		return offhand.getID() != "weapon.holy_water";
	}
});

