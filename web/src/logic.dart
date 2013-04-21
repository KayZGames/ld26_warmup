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