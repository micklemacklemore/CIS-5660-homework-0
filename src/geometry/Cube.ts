import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable {
    indices: Uint32Array;
    positions: Float32Array;
    normals: Float32Array;
    center: vec4;
    size: number;

    constructor(center: vec3, size: number) {
        super(); 
        this.center = vec4.fromValues(center[0], center[1], center[2], 1); 
        this.size = size; 
    }

    create(): void {
        const halfSize = this.size / 2;

        // TODO: center doesn't do anything

        // Vertex positions for a cube
        this.positions = new Float32Array([
            // Front face
            -halfSize, -halfSize,  halfSize, 1.0,
             halfSize, -halfSize,  halfSize, 1.0,
             halfSize,  halfSize,  halfSize, 1.0,
            -halfSize,  halfSize,  halfSize, 1.0,

            // Back face
            -halfSize, -halfSize, -halfSize, 1.0,
            -halfSize,  halfSize, -halfSize, 1.0,
             halfSize,  halfSize, -halfSize, 1.0,
             halfSize, -halfSize, -halfSize, 1.0,

            // Top face
            -halfSize,  halfSize, -halfSize, 1.0,
            -halfSize,  halfSize,  halfSize, 1.0,
             halfSize,  halfSize,  halfSize, 1.0,
             halfSize,  halfSize, -halfSize, 1.0,

            // Bottom face
            -halfSize, -halfSize, -halfSize, 1.0,
             halfSize, -halfSize, -halfSize, 1.0,
             halfSize, -halfSize,  halfSize, 1.0,
            -halfSize, -halfSize,  halfSize, 1.0,

            // Right face
             halfSize, -halfSize, -halfSize, 1.0,
             halfSize,  halfSize, -halfSize, 1.0,
             halfSize,  halfSize,  halfSize, 1.0,
             halfSize, -halfSize,  halfSize, 1.0,

            // Left face
            -halfSize, -halfSize, -halfSize, 1.0,
            -halfSize, -halfSize,  halfSize, 1.0,
            -halfSize,  halfSize,  halfSize, 1.0,
            -halfSize,  halfSize, -halfSize, 1.0,
        ]);

        // Indices for drawing the cube using triangles
        this.indices = new Uint32Array([
            0, 1, 2,  0, 2, 3,  // Front face
            4, 5, 6,  4, 6, 7,  // Back face
            8, 9, 10,  8, 10, 11, // Top face
            12, 13, 14,  12, 14, 15, // Bottom face
            16, 17, 18,  16, 18, 19, // Right face
            20, 21, 22,  20, 22, 23, // Left face
        ]);

        // Normals for each face of the cube
        this.normals = new Float32Array([
            // Front face
             0,  0,  1,  0,
             0,  0,  1,  0,
             0,  0,  1,  0,
             0,  0,  1,  0,

            // Back face
             0,  0, -1,  0,
             0,  0, -1,  0,
             0,  0, -1,  0,
             0,  0, -1,  0,

            // Top face
             0,  1,  0,  0,
             0,  1,  0,  0,
             0,  1,  0,  0,
             0,  1,  0,  0,

            // Bottom face
             0, -1,  0,  0,
             0, -1,  0,  0,
             0, -1,  0,  0,
             0, -1,  0,  0,

            // Right face
             1,  0,  0,  0,
             1,  0,  0,  0,
             1,  0,  0,  0,
             1,  0,  0,  0,

            // Left face
            -1,  0,  0,  0,
            -1,  0,  0,  0,
            -1,  0,  0,  0,
            -1,  0,  0,  0,
        ]);

        this.generateIdx();
        this.generatePos();
        this.generateNor();

        this.count = this.indices.length;
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

        gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
        gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);

        gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
        gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

        console.log("Created cube.")
    }
}

export default Cube; 