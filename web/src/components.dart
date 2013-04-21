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
  num x = 0, y = 0;
}