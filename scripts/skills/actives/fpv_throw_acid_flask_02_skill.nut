this.fpv_throw_acid_flask_02_skill <- this.inherit("scripts/skills/actives/fpv_base_skill", {
	m = {},
	function create()
	{
		this.fpv_base_skill.create();
		this.m.ID = "actives.fpv_throw_acid_flask_02";
		this.m.Name = "Falcon Holy water";
		this.m.Description = "Use your falcon to drop a flask of acid towards a target, where it will shatter and spray its contents. The acid will slowly corrode away any armor of those hit - friend and foe alike.";
		this.m.Icon = "skills/fpv_active_cr_03.png";
		this.m.IconDisabled = "skills/fpv_active_106_sw.png";
		this.m.Overlay = "active_106";
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
			icon = "ui/icons/special.png",
			text = "Reduces the target\'s armor by [color=" + this.Const.UI.Color.DamageValue + "]25%[/color] each turn for 3 turns"
		});
		ret.push({
			id = 6,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Has a [color=" + this.Const.UI.Color.DamageValue + "]33%[/color] chance to hit bystanders at the same or lower height level as well"
		});
		ret.push({
			id = 5,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Lasts for at least [color=" + this.Const.UI.Color.PositiveValue + "]" + 2 + "[/color] turns"
		});
		return ret;
	}

	function getAffectedTiles (_targetTile, _user) {
		return this.getAffectedTile(_targetTile, _user);
	}

	function applyEffect(_target) {
		if (_target.getFlags().has("lindwurm"))
			return;

		if ((_target.getFlags().has("body_immune_to_acid") || _target.getArmor(this.Const.BodyPart.Body) <= 0) && (_target.getFlags().has("head_immune_to_acid") || _target.getArmor(this.Const.BodyPart.Head) <= 0))
			return;

		local poison = _target.getSkills().getSkillByID("effects.acid_strong");
		if (poison == null)
			_target.getSkills().add(this.new("scripts/skills/effects/acid_effect_strong"));
		else
			poison.resetTime();

		this.spawnIcon("status_effect_78", _target.getTile());
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
				if (!nextTile.IsOccupiedByActor) {
					for( local i = 0; i < this.Const.Tactical.AcidParticles.len(); i = ++i ) {
						this.Tactical.spawnParticleEffect(true, this.Const.Tactical.AcidParticles[i].Brushes, nextTile, this.Const.Tactical.AcidParticles[i].Delay, this.Const.Tactical.AcidParticles[i].Quantity, this.Const.Tactical.AcidParticles[i].LifeTimeQuantity, this.Const.Tactical.AcidParticles[i].SpawnRate, this.Const.Tactical.AcidParticles[i].Stages);
					}
					continue;
				}
				_data.Skill.applyEffect(nextTile.getEntity());
			}
		}
	}

	function isHidden() {
		local offhand = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Offhand);
		if (offhand == null)
			return true;
		return offhand.getID() != "weapon.acid_flask_02";
	}
});

