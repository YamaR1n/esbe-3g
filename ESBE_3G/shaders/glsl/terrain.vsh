// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.
#ifdef GL_FRAGMENT_PRECISION_HIGH
	#define HM highp
#else
	#define HM mediump
#endif
#include "vertexVersionCentroid.h"
#if __VERSION__ >= 300
	#ifndef BYPASS_PIXEL_SHADER
		_centroid out vec2 uv0;
		_centroid out vec2 uv1;
	#endif
#else
	#ifndef BYPASS_PIXEL_SHADER
		varying vec2 uv0;
		varying vec2 uv1;
	#endif
#endif

#ifndef BYPASS_PIXEL_SHADER
	varying vec4 color;
#endif

#ifdef FOG
	varying float fog;
#endif

#include "uniformWorldConstants.h"
#include "uniformPerFrameConstants.h"
#include "uniformRenderChunkConstants.h"

attribute POS4 POSITION;
attribute vec4 COLOR;
attribute vec2 TEXCOORD_0;
attribute vec2 TEXCOORD_1;

void main(){
POS4 worldPos;
#ifdef AS_ENTITY_RENDERER
	POS4 pos=WORLDVIEWPROJ*POSITION;
	worldPos=pos;
#else
	worldPos.xyz=(POSITION.xyz*CHUNK_ORIGIN_AND_SCALE.w)+CHUNK_ORIGIN_AND_SCALE.xyz;
	worldPos.w=1.;
	POS4 pos=WORLDVIEW*worldPos;
	pos=PROJ*pos;
#endif
gl_Position=pos;

#ifndef BYPASS_PIXEL_SHADER
	uv0=TEXCOORD_0;
	uv1=TEXCOORD_1;
	color=COLOR;
#endif


#ifdef FOG
	float len=length(-worldPos.xyz)/RENDER_DISTANCE;
	#ifdef ALLOW_FADE
		len+=RENDER_CHUNK_FOG_ALPHA;
	#endif
	fog=clamp((len-FOG_CONTROL.x)/(FOG_CONTROL.y-FOG_CONTROL.x),0.,1.);
#endif

///// esbe water detection
#ifndef SEASONS
	if(color.a < 0.95 && color.a > 0.05) {
		color=COLOR;
		float cameraDist=length(-worldPos.xyz)/FAR_CHUNKS_DISTANCE;
		color.a=mix(color.a,1.,clamp(cameraDist,0.,1.));
	}
#endif

#ifndef BYPASS_PIXEL_SHADER
	#ifndef FOG
		// If the FOG_COLOR isn't used, the reflection on NVN fails to compute the correct size of the constant buffer as the uniform will also be gone from the reflection data
		color.rgb+=FOG_COLOR.rgb*.000001;
	#endif
#endif
}
