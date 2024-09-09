#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time; 

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos; 

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

// hash12 (https://www.shadertoy.com/view/4djSRW)
float hash(vec2 p)
{
     p *= 2024.1999; 
     vec3 p3  = fract(vec3(p.xyx) * .1031);
     p3 += dot(p3, p3.yzx + 33.33);
     return fract((p3.x + p3.y) * p3.z);
}

float valueNoise(vec2 uv) {
     vec2 gridUV = fract(uv); 
     vec2 gridID = floor(uv);
     gridUV = smoothstep(0., 1., gridUV); 
     float bl = hash(gridID); 
     float br = hash(gridID + vec2(1., 0.)); 
     float b = mix(bl, br, gridUV.x); 
     float ul = hash(gridID + vec2(0., 1.)); 
     float ur = hash(gridID + vec2(1., 1.)); 
     float u = mix(ul, ur, gridUV.x); 
     return mix(b, u, gridUV.y); 
}

float hash13(vec3 p3)
{
     p3 *= 2024.1999; 
     p3  = fract(p3 * .1031);
     p3 += dot(p3, p3.zyx + 31.32);
     return fract((p3.x + p3.y) * p3.z);
}

vec3 hash33( vec3 p )      // this hash is not production ready, please
{                        // replace this by something better
	p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
			  dot(p,vec3(269.5,183.3,246.1)),
			  dot(p,vec3(113.5,271.9,124.6)));

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float valueNoise3D(vec3 pos) {
    vec3 id = floor(pos);               // Find the integer grid cell the point is in
    vec3 uv = fract(pos);               // Find the fractional position within the grid cell

    // Hashing the corner points of the cube
    float blf = hash13(id);                           // Bottom-left-front
    float brf = hash13(id + vec3(1., 0., 0.));        // Bottom-right-front
    float blb = hash13(id + vec3(0., 0., 1.));        // Bottom-left-back
    float brb = hash13(id + vec3(1., 0., 1.));        // Bottom-right-back
    float tlf = hash13(id + vec3(0., 1., 0.));        // Top-left-front
    float trf = hash13(id + vec3(1., 1., 0.));        // Top-right-front
    float tlb = hash13(id + vec3(0., 1., 1.));        // Top-left-back
    float trb = hash13(id + vec3(1., 1., 1.));        // Top-right-back

    // Interpolate along the x-axis
    float bFront = mix(blf, brf, uv.x);    // Bottom front interpolation
    float bBack  = mix(blb, brb, uv.x);    // Bottom back interpolation
    float tFront = mix(tlf, trf, uv.x);    // Top front interpolation
    float tBack  = mix(tlb, trb, uv.x);    // Top back interpolation

    // Interpolate along the y-axis
    float bottom = mix(bFront, bBack, uv.z);  // Bottom interpolation
    float top    = mix(tFront, tBack, uv.z);  // Top interpolation

    // Final interpolation along the z-axis
    return mix(bottom, top, uv.y);        // Final trilinear interpolation
}

float perlinNoise( in vec3 x )
{
    // grid
    vec3 p = floor(x);
    vec3 w = fract(x);
    
    // quintic interpolant
    vec3 u = w*w*w*(w*(w*6.0-15.0)+10.0);

    
    // gradients
    vec3 ga = hash33( p+vec3(0.0,0.0,0.0) );
    vec3 gb = hash33( p+vec3(1.0,0.0,0.0) );
    vec3 gc = hash33( p+vec3(0.0,1.0,0.0) );
    vec3 gd = hash33( p+vec3(1.0,1.0,0.0) );
    vec3 ge = hash33( p+vec3(0.0,0.0,1.0) );
    vec3 gf = hash33( p+vec3(1.0,0.0,1.0) );
    vec3 gg = hash33( p+vec3(0.0,1.0,1.0) );
    vec3 gh = hash33( p+vec3(1.0,1.0,1.0) );
    
    // projections
    float va = dot( ga, w-vec3(0.0,0.0,0.0) );
    float vb = dot( gb, w-vec3(1.0,0.0,0.0) );
    float vc = dot( gc, w-vec3(0.0,1.0,0.0) );
    float vd = dot( gd, w-vec3(1.0,1.0,0.0) );
    float ve = dot( ge, w-vec3(0.0,0.0,1.0) );
    float vf = dot( gf, w-vec3(1.0,0.0,1.0) );
    float vg = dot( gg, w-vec3(0.0,1.0,1.0) );
    float vh = dot( gh, w-vec3(1.0,1.0,1.0) );
	
    // interpolation
    return va + 
           u.x*(vb-va) + 
           u.y*(vc-va) + 
           u.z*(ve-va) + 
           u.x*u.y*(va-vb-vc+vd) + 
           u.y*u.z*(va-vc-ve+vg) + 
           u.z*u.x*(va-vb-ve+vf) + 
           u.x*u.y*u.z*(-va+vb+vc-vd+ve-vf-vg+vh);
}

#define OCTAVES 16
#define PERSISTANCE 0.5;
#define LACUNARITY 2.0; 
float fbm(vec3 position) {
     float amplitude = 2.5; 
     float frequency = 3.5; 
     float total = 0.; 

     for (int i = 0; i < OCTAVES; ++i) {
          total += perlinNoise(position * frequency) * amplitude; 
          amplitude *= PERSISTANCE; 
          frequency *= LACUNARITY; 
     }
     return clamp(total, -1., 1.);
}

float turbulencefbm(vec3 p, int octaves, float persistance, float lacunarity) {
     float amplitude = 35987.5; 
     float frequency = 1.0; 
     float total = 0.0; 
     float normalization = 0.0; 

     for (int i = 0; i < octaves; ++i) {
          float noiseValue = perlinNoise(p * frequency); 
          noiseValue = abs(noiseValue);

          total += noiseValue * amplitude; 
          normalization += amplitude; 
          amplitude *= persistance; 
          frequency *= lacunarity; 
     }

     total /= normalization; 

     return total; 
}

float remap(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

vec3 remap(vec3 value, float min1, float max1, float min2, float max2) {
  return vec3(min2) + (value - vec3(min1)) * (vec3(max2) - vec3(min2)) / (vec3(max1) - vec3(min1));
}

#if 0

void main()
{
     vec3 uvw = fs_Pos.xyz; 

     // uv *= 40.;
     // uv *= 20.; 

     vec3 color = vec3(fbm(uvw)); 
     // color = vec3( fract(sin( 3340. * uvw.xy) * 23423.32), 2. ); 
     //color = hash33(uvw); 
     // color = step(0.5, color);
     color = remap(color, -1., 1., 0.0, 1.0);
     if (color.x > .4 && color.x < .8) {
          color.yz = vec2(0.); 
     } else if (color.x > .8 && color.x < 1.) {
          color = vec3(0.790, 0.292, 0.0237);
     } else if(color.x == 1.) {
          color = vec3(0.970, 0.735, 0.427);  
     }else {
          color.xyz = vec3(0.2, .05, 0.01); 
     }
     out_Col = vec4(color, 1.); 
}

#else


void main() {
     vec3 uvw = fs_Pos.xyz; 
     vec3 color = vec3(1.); 

     uvw *= 2.4; 

     float noiseSample = turbulencefbm(uvw, 8, 0.5, 2.0); 
     
     noiseSample = remap(noiseSample, -1., 1., -.0, 1.);
     noiseSample = smoothstep(0.4, .6, noiseSample); 
     noiseSample = clamp(noiseSample, 0., 1.); 

     vec3 basecolor = vec3(1.) - u_Color.xyz; 
     noiseSample = 1. - noiseSample; 
     
     color -= basecolor * vec3(noiseSample); 
    

     out_Col = vec4(color, 1.);
}

#endif