var _matrix = matrix_build_identity();
_matrix = matrix_multiply(_matrix, matrix_build(0, 0, 0, -90, 90, 0, 1, 1, 1));
_matrix = matrix_multiply(_matrix, matrix_build(gunOffset.X, gunOffset.Y, gunOffset.Z, 0, 0, 0, 1, 1, 1));
_matrix = matrix_multiply(_matrix, matrix_build(0, 0, 0, 0, camera.DirectionUp + gunDirectionUp, 0, 1, 1, 1));
_matrix = matrix_multiply(_matrix, matrix_build(0, 0, 0, 0, 0, camera.Direction + gunDirection, 1, 1, 1));
_matrix = matrix_multiply(_matrix, matrix_build(x, y, z + camera.Offset.Z, 0, 0, 0, 1, 1, 1));
matrix_set(matrix_world, _matrix);
FPS_OMain.modBlaster.render();