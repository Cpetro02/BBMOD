////////////////////////////////////////////////////////////////////////////////
// Resize GUI to fit the window
var _windowWidth = window_get_width();
var _windowHeight = window_get_height();

display_set_gui_maximize(1, 1);
display_set_gui_size(_windowWidth, _windowHeight);

////////////////////////////////////////////////////////////////////////////////
// Draw GUI
draw_sprite_ext(FPS_SprCrosshair, 0, _windowWidth * 0.5, _windowHeight * 0.5, 1, 1, 0, c_red, 1);