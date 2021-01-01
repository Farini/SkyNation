
// Uniforms names
// u_size: float: GLKVector3Make(Float(UIScreen.main.scale * size.width), Float(UIScreen.main.scale * size.height), Float(0)))
// u_fill_colour: float: GLKVector4Make(131.0 / 255.0, 149.0 / 255.0, 255.0 / 255.0, 1.0))
// u_border_colour = float: GLKVector4Make(104.0 / 255.0, 119.0 / 255.0, 204.0 / 255.0, 1.0))
// u_total_animation_duration: float: Float(transitionDuration))
// u_elapsed_time: float: Float(0)
// shader.uniforms = [u_size, u_fill_colour, u_border_colour, u_total_animation_duration, u_elapsed_time]

void main( void ) {
    int NUM_COLUMNS = 50;
    
    float tileSize = u_size.x / float(NUM_COLUMNS);
    int NUM_ROWS = int(ceil(u_size.y / tileSize));
    
    int column = int(floor(gl_FragCoord.x / tileSize));
    int row = int(floor(gl_FragCoord.y / tileSize));
    
    vec2 pos = mod(gl_FragCoord.xy, vec2(tileSize)) - vec2(tileSize / 2.0);
    float individualTileAnimationDuration = u_total_animation_duration / 3.0;
    float animStartOffset = (float(NUM_ROWS - row) / float(NUM_ROWS)) * (u_total_animation_duration - individualTileAnimationDuration);
    float elapsedTileAnimTime = min(max(0.0, u_elapsed_time - animStartOffset), individualTileAnimationDuration);
    float tileRadius = (elapsedTileAnimTime / individualTileAnimationDuration) * (tileSize + 3.0);
    
    if (abs(pos.x) + abs(pos.y) < tileRadius - 3.0) {
        gl_FragColor = u_fill_colour;
    } else if (abs(pos.x) + abs(pos.y) < tileRadius) {
        gl_FragColor = u_border_colour;
    } else {
        gl_FragColor = SKDefaultShading();
    }
}
