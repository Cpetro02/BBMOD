////////////////////////////////////////////////////////////////////////////////
// Enable/disable mouselook
var _clicked = mouse_check_button_pressed(mb_left);

if (camera.MouseLook)
{
	if (keyboard_check_pressed(vk_escape))
	{
		camera.set_mouselook(false);
		window_set_cursor(cr_default);
	}
}
else
{
	if (_clicked)
	{
		camera.set_mouselook(true);
		window_set_cursor(cr_none);
		_clicked = false;
	}
}

////////////////////////////////////////////////////////////////////////////////
// Control walking
var _speed = 1;

if (keyboard_check(ord("W")))
{
	x += lengthdir_x(_speed, camera.Direction);
	y += lengthdir_y(_speed, camera.Direction);
}

if (keyboard_check(ord("S")))
{
	x -= lengthdir_x(_speed, camera.Direction);
	y -= lengthdir_y(_speed, camera.Direction);
}

if (keyboard_check(ord("A")))
{
	x += lengthdir_x(_speed, camera.Direction + 90);
	y += lengthdir_y(_speed, camera.Direction + 90);
}

if (keyboard_check(ord("D")))
{
	x += lengthdir_x(_speed, camera.Direction - 90);
	y += lengthdir_y(_speed, camera.Direction - 90);
}

if (z == 0 && keyboard_check_pressed(vk_space))
{
	zspeed = 1.5;
}

z += zspeed;
zspeed -= 0.1;

if (z < 0)
{
	z = 0;
	zspeed = 0;
}

////////////////////////////////////////////////////////////////////////////////
// Update camera

// Backup camera's direction before the update script. We will use this to
// slightly rotate the gun when the camera moves.
var _direction = camera.Direction;
var _directionUp = camera.DirectionUp;

camera.update(delta_time);

////////////////////////////////////////////////////////////////////////////////
// Rotate gun based on camera's motion

// Slowly return gun to its neutral position.
gunDirection *= 0.9;
gunDirectionUp *= 0.9;

// Rotate gun based on the camera's previous direction.
gunDirection += (_direction - camera.Direction) * 0.1;
gunDirectionUp += (_directionUp - camera.DirectionUp) * 0.1;

// Limit the gun rotation so it doesn't move out of the view.
gunDirection = clamp(gunDirection, -10, 10);
gunDirectionUp = clamp(gunDirectionUp, -10, 10);