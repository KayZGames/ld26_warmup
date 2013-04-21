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
  TagManager tm;
  ComponentMapper<Status> statusMapper;
  ComponentMapper<Score> scoreMapper;
  CqWrapper gameWrapper;

  HudRenderSystem(this.gameWrapper);

  initialize() {
    tm = world.getManager(TagManager);
    statusMapper = new ComponentMapper<Status>(Status, world);
    scoreMapper = new ComponentMapper<Score>(Score, world);
  }

  processSystem() {
    var player = tm.getEntity(TAG_PLAYER);
    var status = statusMapper.get(player);
    var score = scoreMapper.get(player);
    gameWrapper..fillStyle = '#140c1c'
               ..font = '18px Verdana'
               ..fillText('Score: ${score.score}', 10, MAX_HEIGHT - 25)
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