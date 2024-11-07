::ModFPVDrone.getAffectedTiles <- function(_skill, _targetTile) {
    local ret = [];
    local ownTile = _skill.m.Container.getActor().getTile();
    local dir = ownTile.getDirectionTo(_targetTile);
    local forwardTile = null;
    if (_targetTile.hasNextTile(dir)) {
        forwardTile = _targetTile.getNextTile(dir);
        if (this.Math.abs(forwardTile.Level - ownTile.Level) <= _skill.m.MaxLevelDifference) {
            dir = ownTile.getDirectionTo(forwardTile);
            forwardTile = forwardTile.getNextTile(dir);
            if (this.Math.abs(forwardTile.Level - ownTile.Level) <= _skill.m.MaxLevelDifference)
                ret.push(forwardTile);
        }
    }
    for( local i = 0; i != 6; i++) {
        if (forwardTile.hasNextTile(i)) {
            local tile = forwardTile.getNextTile(i);
            ret.push(tile);
        }
    }
    return ret;
}