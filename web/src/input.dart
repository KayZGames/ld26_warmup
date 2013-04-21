part of ld26_warmup;

class MotionControlSystem extends VoidEntitySystem {
  Velocity v;
  var pressedKeys = new Map<int, bool>();

  initialize() {
    TagManager tm = world.getManager(TagManager);
    var e = tm.getEntity(TAG_PLAYER);
    v = e.getComponentByClass(Velocity);

    window.onKeyDown.listen((e) => pressedKeys[e.keyCode] = true);
    window.onKeyUp.listen((e) => pressedKeys[e.keyCode] = false);
  }

  processSystem() {
    v.x = right ? 0.2 : left ? -0.2 : 0;
    v.y = down ? 0.2 : up ? -0.2 : 0;
  }

  get left => pressedKeys[KeyCode.LEFT] == true || pressedKeys[KeyCode.A] == true;
  get right => pressedKeys[KeyCode.RIGHT] == true || pressedKeys[KeyCode.D] == true;
  get up => pressedKeys[KeyCode.UP] == true || pressedKeys[KeyCode.W] == true;
  get down => pressedKeys[KeyCode.DOWN] == true || pressedKeys[KeyCode.S] == true;

}