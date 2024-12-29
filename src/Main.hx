import h2d.col.Point;
import h2d.Scene;
import hxd.Rand;

class Main extends hxd.App {
	var cat_paw: CatPaw;
	var fishes:Array<Fish> = [];
	var points = 0;
	var pt: h2d.Text;
	var original_s2d:Scene;
	public static var app : Main;
	override function init() {
		hxd.Res.initEmbed();
		s2d.scaleMode = LetterBox(320, 260, true);
		engine.backgroundColor = 0x2255BB;
		original_s2d = s2d;
		cat_paw = new CatPaw(s2d);
		pt = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		restart();
	}

	public function restart() {
		setScene( original_s2d );
		points = 0;
		pt.text = "Points" + points;

		cat_paw.x = s2d.width * 0.5;
		cat_paw.y = s2d.height * 0.5;
		var bounds = h2d.col.Bounds.fromPoints(new Point(0,0), new Point(s2d.width, s2d.height));
		fishes = [];
		for(i in 0...12) {
			spawn_fish(fishes, bounds);
		}

	};

	// on each frame
	override function update(dt:Float) {
		var px = s2d.mouseX;
		var py = s2d.mouseY;

		cat_paw.x = px;
		cat_paw.y = py;
		for (fish in fishes){
			fish.swim(dt);
			if (hxd.Key.isPressed( hxd.Key.MOUSE_LEFT )){
				var collider = new h2d.col.Circle(cat_paw.x, cat_paw.y, 30);
				var g = new h2d.Graphics(s2d);
				g.beginFill(0xFF00FF);
				// g.drawCircle(cat_paw.x, cat_paw.y, 30);
				if (collider.contains( new Point(fish.x, fish.y))){
					points += 1;
					pt.text = "Points" + points;
					s2d.removeChild(fish);
					fishes.remove(fish);
					if (points >= 12){
						setScene( new Win(this));

					}
				}
			}
		}
	}


	function spawn_fish(array, bounds){
		var fish = new Fish(s2d, bounds);
		s2d.add(fish);
		array.push(fish);
	}

	static function main() {
		new Main();
	}
}

class CatPaw extends h2d.Object {
	var sprite:h2d.Bitmap;
	public function new(s2d){
		super(s2d);
		var paw_sprite = hxd.Res.img.CatPaw_png;
		var paw_tile = paw_sprite.toTile();
		paw_tile.setCenterRatio(0.5, 0.95);
		sprite = new h2d.Bitmap(paw_tile, this);
		this.addChild(sprite);
	}
}


class Fish extends h2d.Object {
	var sprite:h2d.Bitmap;
	var vel_y:Float;
	var vel_x:Float;
	var speed = 100;
	var fish_sprites:Array<h2d.Tile> = 
		[hxd.Res.img.fish1.toTile(), hxd.Res.img.fish2.toTile(), hxd.Res.img.fish3.toTile()];
	var rand = Rand.create();

	var bounds:h2d.col.Bounds;
	public function new (s2d:h2d.Scene, _bounds:h2d.col.Bounds){
		super();
		bounds = _bounds;
		rand.shuffle(fish_sprites);
		fish_sprites[0].setCenterRatio();
		sprite = new h2d.Bitmap(fish_sprites[0]);
		this.addChild(sprite);
		x = rand.random(s2d.width);
		y = rand.random(s2d.height);
		vel_x = rand.srand();
		vel_y = rand.srand();
	}

	public function swim(_delta:Float){
		bounce(_delta);
		x += vel_x * _delta * speed;
		y += vel_y * _delta * speed;
	}
	function bounce(_delta:Float){
		var f_point: Point = new Point(x + vel_x * speed * _delta, y + vel_y * speed * _delta);
		var n = bounds.contains(f_point);
		if (!n){
			vel_y *= -1;
			vel_x *= -1;
		}
	}
}

class Win extends h2d.Scene {
	public function new(main:Main){
		super();
		var t = new h2d.Text( hxd.res.DefaultFont.get(), this ); 
		t.setPosition( 50,  50 );
		t.scale( 3 ); t.textColor = 0xFFCCCC;
		t.text = "You Win!";

		var t = new h2d.Text( hxd.res.DefaultFont.get(), this ); 
		t.setPosition( 50,  150 );
		t.scale( 2 ); t.textColor = 0xFFCCCC;
		t.text = "12 points!";

		var t = new h2d.Text( hxd.res.DefaultFont.get(), this );
		t.setPosition( 50, 200 );
		t.text = "Try Again?";
		
		var interactive = new h2d.Interactive(60, 30, t);
		interactive.onClick = function(event : hxd.Event ){
			main.restart();
		}
	}
}
