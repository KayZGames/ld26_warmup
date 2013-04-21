library ld26_warmup;

import 'dart:async';
import 'dart:html';
import 'package:dartemis/dartemis.dart';
import 'package:canvas_query/canvas_query.dart';

part 'src/components.dart';
part 'src/rendering.dart';
part 'src/input.dart';
part 'src/logic.dart';

const MAX_WIDTH = 500;
const MAX_HEIGHT = 600;

const TAG_PLAYER = 'player';

var images = new Map<String, ImageElement>();

void main() {
  window.setImmediate(() {
    var gameWrapper = cq('#game');
    gameWrapper.canvas..width = MAX_WIDTH
               ..height = MAX_HEIGHT;
    var imageNames = ['player', 'bullet'];
    var imageLoader = new List<Future>();
    imageNames.forEach((imageName) {
      var img = new ImageElement();
      images[imageName] = img;
      img.src = 'res/$imageName.png';
      imageLoader.add(img.onLoad.first);
    });

    Future.wait(imageLoader).then((_) {
      new Game().start(gameWrapper);
    });
  });
}

class Game {
  var world = new World();
  var lastTime;

  void start(CqWrapper gameWrapper) {
    var tm = new TagManager();
    world.addManager(tm);

    var e = world.createEntity();
    e.addComponent(new Position(MAX_WIDTH ~/ 2, MAX_HEIGHT ~/2));
    e.addComponent(new Renderable('player'));
    e.addComponent(new Velocity());
    e.addComponent(new Gun([[-3, -16], [3, -16]]));
    e.addToWorld();
    tm.register(e, TAG_PLAYER);

    world.addSystem(new PlayerControlSystem());
    world.addSystem(new MovementSystem());
    world.addSystem(new PlayerBoundarySystem());
    world.addSystem(new GunSystem());
    world.addSystem(new RenderingSystem(gameWrapper));

    world.initialize();

    window.animationFrame.then((time) {
      lastTime = time;
      window.animationFrame.then(gameLoop);
    });
  }

  void gameLoop(num time) {
    world.delta = time - lastTime;
    lastTime = time;
    world.process();
    window.animationFrame.then(gameLoop);
  }
}


