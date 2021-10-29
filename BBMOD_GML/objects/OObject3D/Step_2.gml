z += zspeed;
zspeed -= 0.1;

if (z < 0)
{
	z = 0;
	zspeed = 0;
}

xprevious = x;
yprevious = y;
zprevious = z;