part of ld26_warmup;

class Position extends Component {
  num x, y;
  Position(this.x, this.y);
}

class Renderable extends Component {
  String name;
  Renderable(this.name);
}

class Velocity extends Component {
  num x, y;
  Velocity({this.x : 0, this.y : 0});
}

class Gun extends Component {
  bool canShoot = true, shoot = false;
  num velX = 0, velY = -0.5;
  num cooldown = 0, maxCooldown = 500;
  List<List<int>> offset;
  Gun(this.offset);
}

