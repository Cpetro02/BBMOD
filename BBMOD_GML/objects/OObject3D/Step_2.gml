x += lengthdir_x(speedCurrent * global.gameSpeed, direction);
y += lengthdir_y(speedCurrent * global.gameSpeed, direction);
z += zspeed * global.gameSpeed;

zspeed -= 0.1 * global.gameSpeed;

if (z < 0
	&& x >= 0 && x < room_width
	&& y >= 0 && y < room_height)
{
	z = 0;
	zspeed = 0;
}