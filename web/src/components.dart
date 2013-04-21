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
  num cooldown = 0, maxCooldown = 100;
  List<Bullet> bullets;
  String bulletType = 'bullet';
  Gun(this.bullets);
}

class Bullet {
  num offsetX, offsetY, velocity, angle;
  Bullet({this.offsetX: 0, this.offsetY: 0, this.velocity: 0.5, this.angle: 0});
}

class Status extends Component {
  int hp, maxHp;
  Status({this.hp: 10}) {
    maxHp = hp;
  }
}

class AutoGunner extends Component {}
class OffScreenRespawner extends Component {}