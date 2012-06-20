package 
{
	import away3d.containers.View3D;
	import away3d.materials.BitmapMaterial;
	import away3d.primitives.Plane;

	import net.jansensan.utils.degreesToRadians;

	import com.greensock.TweenMax;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;


	public class Main extends Sprite
	{
		private	const	WIDTH			:uint = 640;
		private	const	HEIGHT			:uint = 640;
		private	const	MATERIAL_WIDTH	:uint = 1024;
		private	const	MATERIAL_HEIGHT	:uint = 1024;

		[Embed(source="assets/images/escher-relativity.png")]
		private	const	EscherImageClass	:Class;


		private	var	_view3D			:View3D;
		private	var	_imageData		:BitmapData;
		private	var	_matrix			:Matrix;
		private	var	_material		:BitmapMaterial;
		private	var	_plane			:Plane;


		// + ----------------------------------------
		//		[ PUBLIC METHODS ]
		// + ----------------------------------------

		public function Main()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}


		private function init():void
		{
			initStage();
			init3D();
			addMouseListener();
			addEventListener(Event.ENTER_FRAME, updateHandler);
		}


		private function initStage():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}


		private function init3D():void
		{
			// get the scale to apply to the image
			_matrix = new Matrix();
			_matrix.scale(MATERIAL_WIDTH / WIDTH, MATERIAL_HEIGHT / HEIGHT);
			
			// create the image data
			_imageData = new BitmapData(MATERIAL_WIDTH, MATERIAL_HEIGHT);
			_imageData.draw	(	new EscherImageClass(),	// source
								_matrix,				// matrix 
								null,					// colorTransform 
								null,					// blendMode 
								null,					// clipRect 
								true					// smoothing
							);
			
			// create the material
			_material = new BitmapMaterial(_imageData, true);
			_material.mipmap = (_imageData.width == _imageData.height);
			_material.bothSides = true;
			
			// create the view
			_view3D = new View3D();
			
			// camera values
			// see away3d.camerasCamera3D's default lens' field of view 
			// in away3d.cameras.lenses.PerspectiveLens
			// it turns out that the field of view is vertical
			var angleY:Number = 60;
			var cameraZ:int = _view3D.camera.z;

			// this position is arbitrary as we will see further
			// useful to calculate the distance between the camera and the plane
			var planeZ:int = 500;
			var distFromCamToPlane:Number = Math.abs(cameraZ) + planeZ;

			// since the field of view is a vertical angle, calculate the height of the plane first
			// use pythagorean theorem to calculate
			// tip for trigonometry: soh-cah-toa
			// toa: tan(angle) = oppositeSide / adjacentSide
			var planeHeight:int = Math.tan(degreesToRadians(angleY * 0.5)) * distFromCamToPlane;
			// and since it was for a rectangle triangle, thus half the size, double the length
			planeHeight *= 2;
			
			// useful for resizing the image
			var aspectRatio:Number = WIDTH / HEIGHT;
			
			// use the aspect ratio to calulcate the width of the plane
			var planeWidth:int = planeHeight * aspectRatio;
			
			// create the plane
			_plane = new Plane(_material, planeWidth, planeHeight);
			_plane.yUp = false;
			_plane.z = planeZ;
			
			// add 3D objects to the scene
			_view3D.scene.addChild(_plane);
			
			// add the away3d view to the display list
			addChild(_view3D);
		}


		private function addMouseListener():void
		{
			stage.addEventListener(MouseEvent.CLICK, mouseEventHandler);
		}


		private function removeMouseListener():void
		{
			stage.removeEventListener(MouseEvent.CLICK, mouseEventHandler);
		}


		private function planeAnimComplete():void
		{
			_plane.rotationX = 0;
			_plane.rotationY = 0;
			addMouseListener();
		}


		// + ----------------------------------------
		//		[ EVENT HANDLERS ]
		// + ----------------------------------------

		private function addedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			init();
		}


		private function mouseEventHandler(event:MouseEvent):void
		{
			// for fun
			
			// flip plane according to where click happens on stage
			/*
			 * visual explanation of the cases:
			 * ┏⁃┳⁃┳⁃┓
			 * ┃1┃2┃3┃
			 * ╋⁃╋⁃╋⁃╋
			 * ┃4┃5┃6┃
			 * ╋⁃╋⁃╋⁃╋
			 * ┃7┃8┃9┃
			 * ┗⁃┻⁃┻⁃┛
			 */
			
			var rotationXTo:int = 0;
			var rotationYTo:int = 0;
			
			// case 1
			if((event.stageX >= 0 && event.stageX < WIDTH * 0.33) && (event.stageY >= 0 && event.stageY < HEIGHT * 0.33))
			{
				rotationXTo = _plane.rotationX + 360;
				rotationYTo = _plane.rotationY + 360;
			}
			
			// case 2
			else if((event.stageX >= WIDTH * 0.33 && event.stageX <= WIDTH * 0.66) && (event.stageY >= 0 && event.stageY < HEIGHT * 0.33))
			{
				rotationXTo = _plane.rotationX + 360;
			}
			
			// case 3
			else if((event.stageX > WIDTH * 0.66 && event.stageX <= WIDTH) && (event.stageY >= 0 && event.stageY < HEIGHT * 0.33))
			{
				rotationXTo = _plane.rotationX + 360;
				rotationYTo = _plane.rotationY - 360;
			}
			
			// case 4
			else if((event.stageX >= 0 && event.stageX <= WIDTH * 0.33) && (event.stageY >= HEIGHT * 0.33 && event.stageY <= HEIGHT * 0.66))
			{
				rotationYTo = _plane.rotationY + 360;
			}
			
			// case 6
			else if((event.stageX >= WIDTH * 0.66 && event.stageX <= WIDTH) && (event.stageY >= HEIGHT * 0.33 && event.stageY <= HEIGHT * 0.66))
			{
				rotationYTo = _plane.rotationY - 360;
			}
			
			// case 7
			else if((event.stageX >= 0 && event.stageX < WIDTH * 0.33) && (event.stageY > HEIGHT * 0.66 && event.stageY <= HEIGHT))
			{
				rotationXTo = _plane.rotationX - 360;
				rotationYTo = _plane.rotationY + 360;
			}
			
			// case 8
			else if((event.stageX >= 0.33 && event.stageX <= WIDTH * 0.66) && (event.stageY > HEIGHT * 0.66 && event.stageY <= HEIGHT))
			{
				rotationXTo = _plane.rotationX - 360;
			}
			
			// case 9
			else if((event.stageX > 0.66 && event.stageX <= WIDTH) && (event.stageY > HEIGHT * 0.66 && event.stageY <= HEIGHT))
			{
				rotationXTo = _plane.rotationX - 360;
				rotationYTo = _plane.rotationY - 360;
			}
			
			// prevent clicking while tweening
			removeMouseListener();
			
			// animate plane
			TweenMax.to	(	_plane, 
							1.5, 
							{	rotationX:rotationXTo, 
								rotationY:rotationYTo, 
								onComplete:planeAnimComplete
							}
						);
		}


		private function updateHandler(event:Event):void
		{
			if(_view3D) _view3D.render();
		}
	}
}
