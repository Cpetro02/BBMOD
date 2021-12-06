// Render scene into the app. surface
surface_set_target(application_surface);
draw_clear(c_black);
with (FPS_OPlayer)
{
	camera.apply();
	break;
}
matrix_set(matrix_world, matrix_build_identity());
//draw_sprite(BBMOD_SprCheckerboard, 0, 0, 0);
renderer.render();
surface_reset_target();

// Render the app. surface onto the screen
matrix_set(matrix_world, matrix_build_identity());
renderer.present();