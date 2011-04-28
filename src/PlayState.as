package
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		public var toggle:Boolean;
		
		protected const _bloom:uint = 6;	//How much light bloom to have - larger numbers = more
		protected var _fx:FlxSprite;		//Our helper sprite - basically a mini screen buffer (see below)
		protected var _emitter:FlxEmitter;	//The _emitter that spews things off the bottom of the screen. (see below)
		protected var _smallBuffer:FlxSprite;
	
		//This is where everything gets set up for the game state
		override public function create():void
		{
			//Title text, nothing crazy here!
			var text:FlxText;
			text = new FlxText(FlxG.width/4,FlxG.height/2-20,FlxG.width/2,"FlxBloom",true);
			text.setFormat(null,32,FlxG.WHITE,"center");
			add(text);
			text = new FlxText(FlxG.width/4,FlxG.height/2+20,FlxG.width/2,"press space to toggle",true);
			text.setFormat(null,16,FlxG.BLUE,"center");
			add(text);
			
			//This is the sprite we're going to use to help with the light bloom effect
			//First, we're going to initialize it to be a fraction of the screens size
			_fx = new FlxSprite();
			_fx.makeGraphic(FlxG.width/_bloom,FlxG.height/_bloom,0,true);
			_fx.setOriginToCorner();	//Zero out the origin so scaling goes from top-left, not from center
			_fx.scale.x = _bloom;		//Scale it up to be the same size as the screen again
			_fx.scale.y = _bloom;		//Scale it up to be the same size as the screen again
			_fx.antialiasing = true;	//Set AA to true for maximum blurry
			_fx.blend = "screen";		//Set blend mode to "screen" to make the blurred copy transparent and brightening
			//Note that we do not add it to the game state!  It's just a helper, not a "real" sprite.
			
			//Then we scale the screen buffer down, so it draws a smaller version of itself
			// into our tiny FX buffer, which is already scaled up.  The net result of this operation
			// is a blurry image that we can render back over the screen buffer to create the bloom.
			//FlxG.camera.screen.scale.x = 1/_bloom;
			//FlxG.camera.screen.scale.y = 1/_bloom;

            //create a scalled buffer
            //this replaces the scalling of the screen buffer
            _smallBuffer = new FlxSprite();
            _smallBuffer.makeGraphic(FlxG.width, FlxG.height, 0, true);
            _smallBuffer.origin = new FlxPoint(0,0);
            _smallBuffer.scale = new FlxPoint(1/_bloom, 1/_bloom);

			//This is the particle _emitter that spews things off the bottom of the screen.
			//I'm not going to go over it in too much detail here, but basically we
			// create the _emitter, then we create 50 16x16 sprites and add them to it.
			var particles:uint = 50;
			//var _emitter:Flx_emitter = new Flx_emitter(0,FlxG.height+8,particles);
			_emitter = new FlxEmitter(0, FlxG.height+8, particles);
			_emitter.width = FlxG.width;
			_emitter.y = FlxG.height+20;
			_emitter.gravity = -40;
			_emitter.setXSpeed(-20,20);
			_emitter.setYSpeed(-75,-25);
			var particle:FlxParticle;
			var colors:Array = new Array(FlxG.BLUE, (FlxG.BLUE | FlxG.GREEN), FlxG.GREEN, (FlxG.GREEN | FlxG.RED), FlxG.RED);
			for(var i:uint = 0; i < particles; i++)
			{
				particle = new FlxParticle();
				particle.makeGraphic(32,32,colors[int(FlxG.random()*colors.length)]);
				particle.exists = false;
				_emitter.add(particle);
			}
			_emitter.start(false,0,0.1);
			add(_emitter);
			
			//Allows users to toggle the effect on and off with the space bar. Effect starts on.
			toggle = true;
		}
		
		override public function update():void
		{
			if(FlxG.keys.justPressed("SPACE"))
				toggle = !toggle;
				
			super.update();
		}
		
		//This is where we do the actual drawing logic for the game state
		override public function draw():void
		{
			//This draws all the game objects
			super.draw();
			
			if(toggle)
			{
				//The actual blur process is quite simple now.
				//First, we stamp the sprites we want to bloom on the buffer
				for each(var s:FlxSprite in _emitter.members)
				{
					if(s.exists)
						_smallBuffer.stamp(s, s.x, s.y);
				}
				//Then we draw the contents of the _smallBuffer onto the tiny FX buffer;
				_fx.stamp(_smallBuffer);
				//Then we draw the scaled-up contents of the FX buffer back onto the screen:
				_fx.draw();
				_smallBuffer.fill(0xFF000000);
			}
		}
	}
}
