z = 0;
zspeed = 0;

camera = new BBMOD_Camera();
camera.FollowObject = self;
camera.Offset = new BBMOD_Vec3(0, 0, 10);

gunOffset = new BBMOD_Vec3(
	0.5, // Moves gun closer/further from the camera
	0.15, // Moves gun to the right/left
	-0.25 // Moves gun up/down
);

gunDirection = 0; // Rotates gun left/right
gunDirectionUp = 0; // Rotates gun up/down