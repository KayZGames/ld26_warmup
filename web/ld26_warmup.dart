library ld26_warmup;

import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:dartemis/dartemis.dart';
import 'package:canvas_query/canvas_query.dart';

part 'src/components.dart';
part 'src/rendering.dart';
part 'src/input.dart';
part 'src/logic.dart';

const MAX_WIDTH = 500;
const MAX_HEIGHT = 600;
const NPE_MIN_X = -MAX_WIDTH ~/ 2;
const NPE_MIN_Y = -16;
const NPE_MAX_X = MAX_WIDTH - NPE_MIN_X;
const NPE_MAX_Y = MAX_HEIGHT - NPE_MIN_Y;
const NPE_MAX_WIDTH = NPE_MAX_X - NPE_MIN_X;
const NPE_MAX_HEIGHT = NPE_MAX_Y - NPE_MIN_Y;

const TAG_PLAYER = 'player';

var images = new Map<String, ImageElement>();
var random = new Random();

void main() {
  window.setImmediate(() {
    var gameWrapper = cq('#game');
    gameWrapper.canvas..width = MAX_WIDTH
               ..height = MAX_HEIGHT;
    var imageNames = ['player', 'bullet',
                      'tree-0', 'tree-1', 'tree-2', 'tree-3',
                      'enemy-0', 'enemy-1', 'enemy-2', 'enemy-3', 'enemy-bullet'];
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

    createBackground();

    var e = world.createEntity();
    e.addComponent(new Position(MAX_WIDTH ~/ 2, MAX_HEIGHT * 7/8));
    e.addComponent(new Renderable('player'));
    e.addComponent(new Velocity());
    e.addComponent(new Gun([new Bullet(offsetX: -3, offsetY: -16, angle: PI/2),
                            new Bullet(offsetX: 3, offsetY: -16, angle: PI/2)]));
    e.addToWorld();
    tm.register(e, TAG_PLAYER);


    world.addSystem(new PlayerControlSystem());
    world.addSystem(new MovementSystem());
    world.addSystem(new PlayerBoundarySystem());
    world.addSystem(new AutoGunnerSystem());
    world.addSystem(new GunSystem());
    world.addSystem(new OffScreenDestructionSystem());
    world.addSystem(new OffScreenRespawnerSystem());
    world.addSystem(new RenderingSystem(gameWrapper));
    world.addSystem(new EnemySpawningSystem());

    world.initialize();

    window.animationFrame.then((time) {
      lastTime = time;
      window.animationFrame.then(gameLoop);
    });
  }

  createBackground() {
    for (int i = 0; i < 40; i++) {
      var e = world.createEntity();
      e.addComponent(new Position(random.nextInt(MAX_WIDTH), NPE_MIN_Y + random.nextInt(NPE_MAX_HEIGHT)));
      e.addComponent(new Renderable('tree-${random.nextInt(4)}'));
      e.addComponent(new Velocity(y: 0.08));
      e.addComponent(new OffScreenRespawner());
      e.addToWorld();
    }
  }

  void gameLoop(num time) {
    world.delta = time - lastTime;
    lastTime = time;
    world.process();
    window.animationFrame.then(gameLoop);
  }
}


