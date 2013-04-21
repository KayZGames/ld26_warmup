part of ld26_warmup;

class MovementSystem extends EntityProcessingSystem {
  ComponentMapper<Position> posMapper;
  ComponentMapper<Velocity> velocityMapper;

  MovementSystem() : super(Aspect.getAspectForAllOf([Position, Velocity]));

  initialize() {
    posMapper = new ComponentMapper<Position>(Position, world);
    velocityMapper = new ComponentMapper<Velocity>(Velocity, world);
  }

  processEntity(e) {
    var pos = posMapper.get(e);
    var velocity = velocityMapper.get(e);

    pos.x += velocity.x * world.delta;
    pos.y += velocity.y * world.delta;
  }
}

class PlayerBoundarySystem extends VoidEntitySystem {
  const MIN_X = 20;
  const MIN_Y = 50;
  const MAX_X = MAX_WIDTH - 20;
  const MAX_Y = MAX_HEIGHT - 10;

  Position pos;

  initialize() {
    TagManager tm = world.getManager(TagManager);
    var e = tm.getEntity(TAG_PLAYER);
    pos = e.getComponentByClass(Position);
  }

  processSystem() {
    var x = pos.x;
    var y = pos.y;
    if (x < MIN_X) {
      pos.x = MIN_X;
    } else if (x > MAX_X) {
      pos.x = MAX_X;
    }
    if (y < MIN_Y) {
      pos.y = MIN_Y;
    } else if (y > MAX_Y) {
      pos.y = MAX_Y;
    }
  }
}

class GunSystem extends EntityProcessingSystem {
  ComponentMapper<Gun> gunMapper;
  ComponentMapper<Position> posMapper;

  GunSystem() : super(Aspect.getAspectForAllOf([Position, Gun]));

  initialize() {
    gunMapper = new ComponentMapper<Gun>(Gun, world);
    posMapper = new ComponentMapper<Position>(Position, world);
  }

  processEntity(e) {
    var gun = gunMapper.get(e);
    if (gun.shoot) {
      var pos = posMapper.get(e);
      var bullet = world.createEntity();
      gun.offset.forEach((offset) {
        var bullet = world.createEntity();
        bullet.addComponent(new Position(pos.x + offset[0], pos.y + offset[1]));
        bullet.addComponent(new Velocity(x: gun.velX, y: gun.velY));
        bullet.addComponent(new Renderable('bullet'));
        bullet.addToWorld();
      });
      gun.cooldown = gun.maxCooldown;
      gun.canShoot = false;
    } else if (!gun.canShoot) {
      if (gun.cooldown > 0) {
        gun.cooldown -= world.delta;
      } else {
        gun.canShoot = true;
      }
    }
  }
}

class OffScreenMovementSystem extends EntityProcessingSystem {
  ComponentMapper<Position> posMapper;
  OffScreenMovementSystem() : super(Aspect.getAspectForAllOf([Position]));
  initialize() {
    posMapper = new ComponentMapper<Position>(Position, world);
  }

  processEntity(Entity e) {
    var pos = posMapper.get(e);
    if (pos.y > NPE_MAX_Y) {
      pos.y = NPE_MIN_Y;
      pos.x = random.nextInt(MAX_WIDTH);
    } else if (pos.y < NPE_MIN_Y) {
      e.deleteFromWorld();
    }
  }
}

class EnemySpawningSystem extends IntervalEntitySystem {
  EnemySpawningSystem() : super(5000, Aspect.getEmpty());

  processEntities(_) {
    var e = world.createEntity();
    e.addComponent(new Position(random.nextInt(MAX_WIDTH), -random.nextInt(-NPE_MIN_Y)));
    e.addComponent(new Renderable('enemy-${random.nextInt(4)}'));
    e.addComponent(new Velocity(y: 0.15));
    e.addToWorld();
  }
}