// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

attribute vec4 position;
attribute vec4 prevPosition;
attribute vec4 nextPosition;
attribute float side;

uniform mat4 transform;

varying LOWP vec4 colorVarying;

vec4 clipToWindowSpace ( vec4 clipPos ) {
	
	float halfWidth = 520.0 / 2.0;
	float halfHeight = 680.0 / 2.0; 
	clipPos.xyz /= clipPos.w;
	clipPos.x *= halfWidth;
	clipPos.y *= halfHeight;
	return clipPos;
}

vec4 windowToClipSpace ( vec4 windowPos ) {
	
	float halfWidth = 520.0 / 2.0;
	float halfHeight = 680.0 / 2.0; 
	windowPos.x /= halfWidth;
	windowPos.y /= halfHeight;
	windowPos.xyz *= windowPos.w;
	return windowPos;
}

void main () {

    colorVarying = vec4 ( 1.0, 0.0, 0.0, 1.0 );

	vec4 currPos = clipToWindowSpace ( position * transform );
	vec4 nextPos = clipToWindowSpace ( nextPosition * transform );
	vec4 prevPos = clipToWindowSpace ( prevPosition * transform );

	float radius = 10.0;
	float miterLimit = 1.0;

    vec2 edge0 = vec2 ( currPos.xy - prevPos.xy );
    vec2 edge1 = vec2 ( nextPos.xy - currPos.xy );

	float length0 = currPos == prevPos ? 0.0 : length ( edge0 );
	float length1 = currPos == nextPos ? 0.0 : length ( edge1 );

	if ( length0 == 0.0 && length1 == 0.0 ) {

		gl_Position = windowToClipSpace ( currPos );
		return;
	}
	else if ( length0 == 0.0 ) {

		edge1 = edge1 / length1;
	    vec4 jointNorm = vec4 ( -edge1.y, edge1.x, 0.0, 0.0 );
	    gl_Position = windowToClipSpace ( currPos + ( jointNorm * radius ));
    }
	else if ( length1 == 0.0 ) {

		edge0 = edge0 / length0;
	    vec4 jointNorm = vec4 ( -edge0.y, edge0.x, 0.0, 0.0 );
	    gl_Position = windowToClipSpace ( currPos + ( jointNorm * radius ));
	}
	else {

		edge0 = edge0 / length0;
		edge1 = edge1 / length1;

	    vec2 edgeNorm0 = vec2 ( -edge0.y, edge0.x );
	    vec2 edgeNorm1 = vec2 ( -edge1.y, edge1.x );

        edgeNorm0 = normalize ( edgeNorm0 );
        edgeNorm1 = normalize ( edgeNorm1 );

        if ( dot ( edgeNorm0, edgeNorm1 ) <= -0.99999 ) {

            vec2 v = side < 0.5 ? edgeNorm0 : edgeNorm1;
            gl_Position = windowToClipSpace ( currPos + vec4 ( v * radius, 0.0, 0.0 ));
            return;
        }

	    vec4 jointNorm = vec4 ( normalize ( edgeNorm0 + edgeNorm1 ), 0.0, 0.0 ) ;
	    
	    float miter = radius / dot ( vec4 ( edgeNorm0, 0.0, 0.0 ), jointNorm );

	    if (( miter / radius ) > miterLimit ) {
			
            if ( dot ( jointNorm.xy, edge1 ) < 0.0 ) {

    	    	float angle = -acos ( dot ( edgeNorm0, edgeNorm1 )) * side;

                vec2 n = edgeNorm0;

                float ca = cos ( angle );
                float sa = sin ( angle );

                vec2 v = vec2 (( n.x * ca ) - ( n.y * sa ), ( n.y * ca ) + ( n.x * sa ));

        		gl_Position = windowToClipSpace ( currPos + vec4 ( v * radius, 0.0, 0.0 ));
            }
            else {

                vec2 v = side < 0.5 ? edgeNorm0 : edgeNorm1;
    	    	gl_Position = windowToClipSpace ( currPos + vec4 ( v * radius, 0.0, 0.0 ));
    	   }
	    }
	    else {

	    	gl_Position = windowToClipSpace ( currPos + ( jointNorm * miter ));
        }		
	}
}