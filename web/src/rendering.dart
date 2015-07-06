part of ld26_warmup;

class RenderingSystem extends EntityProcessingSystem {
  CanvasRenderingContext2D gameWrapper;
  Mapper<Position> posMapper;
  Mapper<Renderable> renderMapper;
  RenderingSystem(this.gameWrapper)
      : super(Aspect.getAspectForAllOf([Position, Renderable]));

  initialize() {
    posMapper = new Mapper<Position>(Position, world);
    renderMapper = new Mapper<Renderable>(Renderable, world);
  }

  begin() {
    gameWrapper
      ..save()
      ..fillStyle = 'green'
      ..fillRect(0, 0, MAX_WIDTH, MAX_HEIGHT)
      ..restore();
  }

  processEntity(e) {
    var pos = posMapper[e];
    var renderable = renderMapper[e];

    var img = images[renderable.name];
    gameWrapper.drawImage(img, pos.x - img.width ~/ 2, pos.y - img.height ~/ 2);
  }
}

class HudRenderSystem extends VoidEntitySystem {
  TagManager tm;
  Mapper<Status> statusMapper;
  CanvasRenderingContext2D gameWrapper;

  HudRenderSystem(this.gameWrapper);

  initialize() {
    tm = world.getManager(TagManager);
    statusMapper = new Mapper<Status>(Status, world);
  }

  processSystem() {
    var player = tm.getEntity(TAG_PLAYER);
    gameWrapper
      ..fillStyle = '#140c1c'
      ..font = '18px Verdana'
      ..fillText('Score: $score', 10, MAX_HEIGHT - 25)
      ..fillRect(MAX_WIDTH / 4, MAX_HEIGHT - 20, MAX_WIDTH / 2, 20);
    if (null != player) {
      var status = statusMapper[player];
      gameWrapper
        ..fillStyle = '#6daa2c'
        ..fillRect(MAX_WIDTH / 4 + 2, MAX_HEIGHT - 18,
            (MAX_WIDTH / 2 - 4) * status.hp / status.maxHp, 16);
    }
  }

  begin() {
    gameWrapper.save();
  }

  end() {
    gameWrapper.restore();
  }
}
