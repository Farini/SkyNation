//
// Applies an interlacing effect where horizontal lines of original color are separated by lines of another color
// Attribute: a_size, the size of the node.
// Uniform: u_width, the width of the interlacing lines. Ranges of 1 to 4 work best; try starting with 1.
// Uniform: u_color, the SKColor to use for interlacing lines. Try starting with black.
// Uniform: u_strength, how much to blend interlaced lines with u_color. Specify 0 (not at all) up to 1 (fully).

// MIT License
// Copyright (c) 2017 Paul Hudson
// https://www.github.com/twostraws/ShaderKit

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

void main() {
    // find the current pixel color
    vec4 current_color = SKDefaultShading();
    
    // if the current color is not transparent
    if (current_color.a > 0.0) {
        // find this pixel's position in the texture
        float this_pixel = a_size[1] * v_tex_coord.y;
        
        // if we are an alternating line (horizontally)
        if (mod(this_pixel, u_width * 2.0) <= u_width) {
            // render the original color, taking into account node transparency
            gl_FragColor = SKDefaultShading() * v_color_mix.a;
        } else {
            // blend the original color with the provided color at whatever strength was requested,
            // multiplying by this pixel's alpha (to avoid a hard edge) and also multiplying by
            // the alpha for this node
            gl_FragColor = vec4(mix(current_color, u_color, u_strength)) * current_color.a * v_color_mix.a;
        }
    } else {
        // use the current (transparent) color
        gl_FragColor = vec4(0, 0, 0, 0);
    }
}
