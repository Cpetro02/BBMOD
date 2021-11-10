duration -= delta_time * 0.001;
if (duration <= 0.0)
{
	instance_destroy();
}