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
  const MAX_Y = MAX_HEIGHT - 30;

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
  GroupManager gm;

  GunSystem() : super(Aspect.getAspectForAllOf([Position, Velocity, Gun]));

  initialize() {
    gunMapper = new ComponentMapper<Gun>(Gun, world);
    posMapper = new ComponentMapper<Position>(Position, world);
    velMapper = new ComponentMapper<Velocity>(Velocity, world);
    gm = world.getManager(GroupManager);
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
        e.addComponent(new Status(hp: 1));
        e.addToWorld();
        gm.add(e, gun.bulletType);
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
  GroupManager gm;
  EnemySpawningSystem() : super(2500, Aspect.getEmpty());

  initialize() {
    gm = world.getManager(GroupManager);
  }

  processEntities(_) {
    for (int i = 0; i < 1 + random.nextInt(1 + score~/250); i++) {
      spawnEnemy();
    }
  }

  void spawnEnemy() {
    var e = world.createEntity();
    e.addComponent(new Position(random.nextInt(MAX_WIDTH), -random.nextInt(-NPE_MIN_Y)));
    int enemy = random.nextInt(4);
    e.addComponent(new Renderable('enemy-$enemy'));
    num bulletV = 0.05 + random.nextDouble() / 20 + score/10000;
    Gun gun;
    switch (enemy) {
      case 0:
      case 1:
        gun = new Gun([new Bullet(offsetX: 0, offsetY: 16, angle: PI * 3/2, velocity: bulletV)]);
        break;
      case 2:
        gun = new Gun([new Bullet(angle: PI * 3/2, velocity: bulletV),
                       new Bullet(angle: PI * 5/4, velocity: bulletV),
                       new Bullet(angle: PI * 7/4, velocity: bulletV)]);
        break;
      case 3:
        gun = new Gun([new Bullet(angle: PI, velocity: bulletV),
                       new Bullet(angle: 0, velocity: bulletV)]);
        break;
    }
    gun.maxCooldown = 1000 + random.nextInt(20000) - score/500;
    gun.bulletType = 'enemy-bullet';
    e.addComponent(gun);
    e.addComponent(new Velocity(y: 0.01 + random.nextDouble() / 10 + score/10000));
    e.addComponent(new AutoGunner());
    e.addComponent(new OffScreenRespawner());
    e.addComponent(new Status(hp: 1 + random.nextInt(4) + score~/500));
    e.addToWorld();
    gm.add(e, GROUP_ENEMY);
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

class BulletCollisionSystem extends VoidEntitySystem {
  GroupManager gm;
  TagManager tm;
  ComponentMapper<Position> posMapper;
  ComponentMapper<Status> statusMapper;

  initialize() {
    gm = world.getManager(GroupManager);
    tm = world.getManager(TagManager);
    posMapper = new ComponentMapper<Position>(Position, world);
    statusMapper = new ComponentMapper<Status>(Status, world);
  }

  processSystem() {
    var playerBullets = gm.getEntities(GROUP_PLAYER_BULLET);
    var enemyBullets = gm.getEntities(GROUP_ENEMY_BULLET);
    var enemies = gm.getEntities(GROUP_ENEMY);
    var player = tm.getEntity(TAG_PLAYER);
    enemies.forEach((enemy) {
      checkCollision(enemy, playerBullets, 3, addScore: true);
    });
    if (null != player) {
      checkCollision(player, enemyBullets, 3);
      checkCollision(player, enemies, 16);
    }
  }

  void checkCollision(Entity e, ReadOnlyBag<Entity> collidables, int radius, {bool addScore: false}) {
    var pos = posMapper.get(e);
    collidables.forEach((collider) {
      var colliderPos = posMapper.get(collider);
      if (Utils.doCirclesCollide(pos.x, pos.y, 16, colliderPos.x, colliderPos.y, radius)) {
        handleCollision(e, addScore);
        handleCollision(collider, false);
      }
    });
  }

  void handleCollision(Entity e, bool addScore) {
    var status = statusMapper.get(e);
    status.hp -= 1;
    if (status.hp == 0) {
      e.deleteFromWorld();
      if (addScore) {
        score += 4;
      }
    } else if (addScore) {
      score += 1;
    }
  }
}

class RepairSystem extends IntervalEntitySystem {
  TagManager tm;
  ComponentMapper<Status> statusMapper;

  RepairSystem() : super(5000, Aspect.getEmpty());

  initialize() {
    tm = world.getManager(TagManager);
    statusMapper = new ComponentMapper<Status>(Status, world);
  }

  processEntities(_) {
    var player = tm.getEntity(TAG_PLAYER);
    if (null != player) {
      var status = statusMapper.get(player);
      if (status.hp < status.maxHp) {
          status.hp += 1;
      }
    }
  }

}