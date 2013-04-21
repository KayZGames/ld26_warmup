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