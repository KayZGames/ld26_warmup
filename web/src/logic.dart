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
  ComponentMapper<Velocity> velMapper;

  GunSystem() : super(Aspect.getAspectForAllOf([Position, Velocity, Gun]));

  initialize() {
    gunMapper = new ComponentMapper<Gun>(Gun, world);
    posMapper = new ComponentMapper<Position>(Position, world);
    velMapper = new ComponentMapper<Velocity>(Velocity, world);
  }

  processEntity(e) {
    var gun = gunMapper.get(e);
    if (!gun.canShoot) {
      if (gun.cooldown > 0) {
        gun.cooldown -= world.delta;
      } else {
        gun.canShoot = true;
      }
    } else if (gun.shoot) {
      var pos = posMapper.get(e);
      var vel = velMapper.get(e);
      gun.bullets.forEach((bullet) {
        var e = world.createEntity();
        e.addComponent(new Position(pos.x + bullet.offsetX, pos.y + bullet.offsetY));
        e.addComponent(new Velocity(x: bullet.velocity * cos(bullet.angle),
                                    y: vel.y + bullet.velocity * sin(-bullet.angle)));
        e.addComponent(new Renderable(gun.bulletType));
        e.addToWorld();
      });
      gun.cooldown = gun.maxCooldown;
      gun.canShoot = false;
    }
  }
}

class OffScreenDestructionSystem extends EntityProcessingSystem {
  ComponentMapper<Position> posMapper;
  OffScreenDestructionSystem() : super(Aspect.getAspectForAllOf([Position]).exclude([OffScreenRespawner]));
  initialize() {
    posMapper = new ComponentMapper<Position>(Position, world);
  }

  processEntity(Entity e) {
    var pos = posMapper.get(e);
    if (pos.y > NPE_MAX_Y || pos.y < NPE_MIN_Y) {
      e.deleteFromWorld();
    }
  }
}

class OffScreenRespawnerSystem extends EntityProcessingSystem {
  ComponentMapper<Position> posMapper;
  OffScreenRespawnerSystem() : super(Aspect.getAspectForAllOf([Position, OffScreenRespawner]));
  initialize() {
    posMapper = new ComponentMapper<Position>(Position, world);
  }

  processEntity(Entity e) {
    var pos = posMapper.get(e);
    if (pos.y > NPE_MAX_Y) {
      pos.y = NPE_MIN_Y;
      pos.x = random.nextInt(MAX_WIDTH);
    }
  }
}

class EnemySpawningSystem extends IntervalEntitySystem {
  EnemySpawningSystem() : super(5000, Aspect.getEmpty());

  processEntities(_) {
    var e = world.createEntity();
    e.addComponent(new Position(random.nextInt(MAX_WIDTH), -random.nextInt(-NPE_MIN_Y)));
    int enemy = random.nextInt(4);
    e.addComponent(new Renderable('enemy-$enemy'));
    Gun gun;
    switch (enemy) {
      case 0:
      case 1:
        gun = new Gun([new Bullet(offsetX: 0, offsetY: 16, angle: PI * 3/2)]);
        break;
      case 2:
        gun = new Gun([new Bullet(angle: PI * 3/2),
                       new Bullet(angle: PI * 5/4),
                       new Bullet(angle: PI * 7/4)]);
        break;
      case 3:
        gun = new Gun([new Bullet(angle: PI),
                       new Bullet(angle: 0)]);
        break;
    }
    gun.maxCooldown = 2000;
    gun.bulletType = 'enemy-bullet';
    e.addComponent(gun);
    e.addComponent(new Velocity(y: 0.15));
    e.addComponent(new AutoGunner());
    e.addComponent(new OffScreenRespawner());
    e.addToWorld();
  }
}

class AutoGunnerSystem extends EntityProcessingSystem {
  ComponentMapper<Gun> gunMapper;

  AutoGunnerSystem() : super(Aspect.getAspectForAllOf([AutoGunner, Gun]));

  initialize() {
    gunMapper = new ComponentMapper<Gun>(Gun, world);
  }

  processEntity(Entity e) {
    var gun = gunMapper.get(e);
    gun.shoot = true;
  }
}