var _windowWidth = window_get_width();
var _windowHeight = window_get_height();
var _x, _y, _text;

// Draw crosshair
if (OPlayer.aiming)
{
	draw_sprite(SprCrosshair, 0,
		round(_windowWidth / 2),
		round(_windowHeight / 2));
}

// Draw cutscene text
var _cutscene = GetCutscene();
if (_cutscene)
{
	var _stage = _cutscene.GetStage();
	_text = _stage.GetText();
	var _textWidth = string_width(_text);
	var _textHeight = string_height(_text);
	_x = round((_windowWidth - _textWidth) * 0.5);
	_y = _windowHeight - _textHeight - 64;

	draw_rectangle_color(_x - 4, _y - 1, _x + _textWidth + 4, _y + _textHeight + 1,
		c_black, c_black, c_black, c_black, false);
	draw_text(_x, _y, _text);
}

// Debug
if (false)
{
	if (renderer.DirectionalLight != undefined)
	{
		var _shadowmap = renderer.DirectionalLight.get_shadowmap_surface();
		draw_surface_stretched(_shadowmap, 0, 0, 256, 256);
	}
}