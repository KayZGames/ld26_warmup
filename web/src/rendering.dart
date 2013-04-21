part of ld26_warmup;

class RenderingSystem extends EntityProcessingSystem {
  CqWrapper gameWrapper;
  ComponentMapper<Position> posMapper;
  ComponentMapper<Renderable> renderMapper;
  RenderingSystem(this.gameWrapper) : super(Aspect.getAspectForAllOf([Position, Renderable]));

  initialize() {
    posMapper = new ComponentMapper<Position>(Position, world);
    renderMapper = new ComponentMapper<Renderable>(Renderable, world);
  }

  begin() {
    gameWrapper.clear(color: 'green');
  }

  processEntity(e) {
    var pos = posMapper.get(e);
    var renderable = renderMapper.get(e);

    var img = images[renderable.name];
    gameWrapper.drawImage(img, pos.x - img.width ~/ 2, pos.y - img.height ~/ 2);
  }
}

class HudRenderSystem extends VoidEntitySystem {
  Status status;
  CqWrapper gameWrapper;

  HudRenderSystem(this.gameWrapper);

  initialize() {
    TagManager tm = world.getManager(TagManager);
    var player = tm.getEntity(TAG_PLAYER);
    status = player.getComponentByClass(Status);
  }

  processSystem() {
    gameWrapper..fillStyle = '#140c1c'
               ..fillRect(MAX_WIDTH / 4, MAX_HEIGHT - 20, MAX_WIDTH / 2, 20)
               ..fillStyle = '#6daa2c'
               ..fillRect(MAX_WIDTH / 4 + 2, MAX_HEIGHT - 18, (MAX_WIDTH / 2 - 4) * status.hp / 10, 16);
  }

  begin() {
    gameWrapper.save();
  }

  end() {
    gameWrapper.restore();
  }
}