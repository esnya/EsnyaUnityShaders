// Upgrade NOTE: upgraded instancing buffer 'EsnyaShadersOsakanaShader' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EsnyaShaders/Osakana Shader"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[Header(PBR Material)][Header(Base Color)]_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		[NoScaleOffset][VisibleIf(_DETAIL_MULX2)]_DetailMask("Detail Mask", 2D) = "white" {}
		[Header(Roughness)][NoScaleOffset]_SpecGlossMap("Roughness Map", 2D) = "white" {}
		_Glossiness("Roughness", Range( 0 , 1)) = 1
		_RoughnessCorrection("Roughness Correction", Float) = 0.45
		[Header(Metallic)][NoScaleOffset]_MetallicGlossMap("Metallic Map", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 1
		[Header(Normal)][Toggle(_NORMALMAP)] _NORMALMAP("Use Normal Map", Float) = 0
		[NoScaleOffset][Normal][EsnyaFactory.VisibleIf(_NORMALMAP)]_BumpMap("Normal Map", 2D) = "bump" {}
		[VisibleIf(_NORMALMAP)]_BumpScale("Normal Scale", Float) = 1
		[Header(Emission)][Toggle(_EMISSION)] _EMISSION("Use Emission", Float) = 0
		[HDR][NoScaleOffset][VisibleIf(_EMISSION)]_EmissionMap("EmissionMap", 2D) = "white" {}
		[HDR][VisibleIf(_EMISSION)]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		[Header(Occlusion)][NoScaleOffset]_OcclusionMap("Occlusion", 2D) = "white" {}
		_OcclusionStrength("Occlusion Strength", Float) = 1
		[Header(Height Map)][Toggle(_PARALLAXMAP)] _PARALLAXMAP("Use Height Map", Float) = 0
		[NoScaleOffset][VisibleIf(_PARALLAXMAP)]_ParallaxMap("Height Map", 2D) = "black" {}
		[VisibleIf(_PARALLAXMAP)]_Parallax("Height Map Scale", Range( 0.005 , 0.08)) = 0.005
		[Header(Use Detail Map)][Toggle(_DETAIL_MULX2)] _DETAIL_MULX2("Use Detail Maps", Float) = 0
		[VisibleIf(_DETAIL_MULX2)]_DetailAlbedoMap("Detail Albedo", 2D) = "white" {}
		[NoScaleOffset][Normal][VisibleIf(_DETAIL_MULX2)]_DetailNormalMap("Detail Normal Map", 2D) = "bump" {}
		[VisibleIf(_DETAIL_MULX2)]_DetailNormalMapScale("Detail Normal Map Scale", Float) = 1
		[Enum(UV1,0,UV2,1)]_UVSetforsecondarytextures("UV Set for secondary textures", Int) = 0
		[Header(Tiling)]_Raws("Raws", Int) = 1
		_Cols("Cols", Int) = 1
		_TileCount("Tile Count", Int) = 1
		_RandomSeed("Random Seed", Float) = 0
		_TileScale("Tile Scale", Vector) = (1,1,0,0)
		_TileOffset("Tile Offset", Vector) = (0,0,0,0)
		[Header(Fish Position)]_PositionNoiseSpeed("Position Noise Speed", Float) = 0.02
		[Enum(Linear,0,Spherical,1)]_PosiitonNoiseSpaceMode("Posiiton Noise Space Mode", Int) = 1
		_PositionNoiseScale("Position Noise Scale", Vector) = (1,1,1,0)
		_RotationOffset("Rotation Offset", Range( -180 , 180)) = 0
		_dT("dT", Float) = 0.001
		[Header(Fish Waving)]_WavingStrength("Waving Strength", Float) = 0.1
		_WavingLength("Waving Length", Float) = 6
		_WavingSpeed("Waving Speed", Float) = 4
		_WavingNoiseSpeed("Waving Noise Speed", Float) = 1
		_WavingNoiseScale("Waving Noise Scale", Float) = 1
		[Header(Fish Scale)]_FishScalePerAxis("Fish Scale Per Axis", Vector) = (1,1,1,0)
		_FishRandomizedScaleMin("Fish Randomized Scale Min", Float) = 0.1
		_FishRandomizedScaleMax("Fish Randomized Scale Max", Float) = 0.2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma shader_feature _DETAIL_MULX2
		#pragma shader_feature _NORMALMAP
		#pragma shader_feature _PARALLAXMAP
		#pragma shader_feature _EMISSION
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float2 uv2_texcoord2;
		};

		uniform sampler2D _BumpMap;
		uniform sampler2D _ParallaxMap;
		uniform float _Parallax;
		uniform float _BumpScale;
		uniform sampler2D _DetailNormalMap;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform int _UVSetforsecondarytextures;
		uniform float _DetailNormalMapScale;
		uniform sampler2D _DetailMask;
		uniform float4 _Color;
		uniform sampler2D _DetailAlbedoMap;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionColor;
		uniform sampler2D _MetallicGlossMap;
		uniform float _Metallic;
		uniform sampler2D _SpecGlossMap;
		uniform float _Glossiness;
		uniform float _RoughnessCorrection;
		uniform sampler2D _OcclusionMap;
		uniform float _OcclusionStrength;
		uniform float _Cutoff = 0.5;

		UNITY_INSTANCING_BUFFER_START(EsnyaShadersOsakanaShader)
			UNITY_DEFINE_INSTANCED_PROP(float4, _DetailAlbedoMap_ST)
#define _DetailAlbedoMap_ST_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float3, _PositionNoiseScale)
#define _PositionNoiseScale_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float3, _FishScalePerAxis)
#define _FishScalePerAxis_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float2, _TileOffset)
#define _TileOffset_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float2, _TileScale)
#define _TileScale_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(int, _Cols)
#define _Cols_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(int, _Raws)
#define _Raws_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float, _RandomSeed)
#define _RandomSeed_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float, _FishRandomizedScaleMax)
#define _FishRandomizedScaleMax_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float, _FishRandomizedScaleMin)
#define _FishRandomizedScaleMin_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float, _WavingNoiseScale)
#define _WavingNoiseScale_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float, _WavingNoiseSpeed)
#define _WavingNoiseSpeed_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float, _WavingStrength)
#define _WavingStrength_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float, _WavingSpeed)
#define _WavingSpeed_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float, _WavingLength)
#define _WavingLength_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float, _RotationOffset)
#define _RotationOffset_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float, _dT)
#define _dT_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(int, _PosiitonNoiseSpaceMode)
#define _PosiitonNoiseSpaceMode_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(int, _TileCount)
#define _TileCount_arr EsnyaShadersOsakanaShader
			UNITY_DEFINE_INSTANCED_PROP(float, _PositionNoiseSpeed)
#define _PositionNoiseSpeed_arr EsnyaShadersOsakanaShader
		UNITY_INSTANCING_BUFFER_END(EsnyaShadersOsakanaShader)


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }

		inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }

		inline float valueNoise (float2 uv)
		{
			float2 i = floor(uv);
			float2 f = frac( uv );
			f = f* f * (3.0 - 2.0 * f);
			uv = abs( frac(uv) - 0.5);
			float2 c0 = i + float2( 0.0, 0.0 );
			float2 c1 = i + float2( 1.0, 0.0 );
			float2 c2 = i + float2( 0.0, 1.0 );
			float2 c3 = i + float2( 1.0, 1.0 );
			float r0 = noise_randomValue( c0 );
			float r1 = noise_randomValue( c1 );
			float r2 = noise_randomValue( c2 );
			float r3 = noise_randomValue( c3 );
			float bottomOfGrid = noise_interpolate( r0, r1, f.x );
			float topOfGrid = noise_interpolate( r2, r3, f.x );
			float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
			return t;
		}


		float SimpleNoise(float2 UV)
		{
			float t = 0.0;
			float freq = pow( 2.0, float( 0 ) );
			float amp = pow( 0.5, float( 3 - 0 ) );
			t += valueNoise( UV/freq )*amp;
			freq = pow(2.0, float(1));
			amp = pow(0.5, float(3-1));
			t += valueNoise( UV/freq )*amp;
			freq = pow(2.0, float(2));
			amp = pow(0.5, float(3-2));
			t += valueNoise( UV/freq )*amp;
			return t;
		}


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 _Vector2 = float3(0,1,0);
			float _PositionNoiseSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(_PositionNoiseSpeed_arr, _PositionNoiseSpeed);
			float mulTime16 = _Time.y * _PositionNoiseSpeed_Instance;
			float2 appendResult15 = (float2(floor( v.texcoord.xy.x ) , mulTime16));
			float3 _PositionNoiseScale_Instance = UNITY_ACCESS_INSTANCED_PROP(_PositionNoiseScale_arr, _PositionNoiseScale);
			float3 break57 = _PositionNoiseScale_Instance;
			float simplePerlin2D14 = snoise( appendResult15*break57.x );
			float2 appendResult39 = (float2(( floor( v.texcoord.xy.x ) + 0.33 ) , mulTime16));
			float simplePerlin2D18 = snoise( appendResult39*break57.y );
			float2 appendResult40 = (float2(( floor( v.texcoord.xy.x ) + 0.66 ) , mulTime16));
			float simplePerlin2D20 = snoise( appendResult40*break57.z );
			float3 appendResult19 = (float3(simplePerlin2D14 , simplePerlin2D18 , simplePerlin2D20));
			float3 appendResult51 = (float3(UNITY_PI , UNITY_PI , 1.0));
			float3 temp_output_49_0 = ( appendResult19 * appendResult51 );
			float3 break9_g5 = temp_output_49_0;
			float temp_output_10_0_g5 = ( break9_g5.x * 1.0 );
			float temp_output_12_0_g5 = sin( temp_output_10_0_g5 );
			float temp_output_11_0_g5 = ( break9_g5.y * 1.0 );
			float3 appendResult19_g5 = (float3(( break9_g5.z * temp_output_12_0_g5 * cos( temp_output_11_0_g5 ) ) , ( break9_g5.z * temp_output_12_0_g5 * sin( temp_output_11_0_g5 ) ) , ( break9_g5.z * cos( temp_output_10_0_g5 ) )));
			int _PosiitonNoiseSpaceMode_Instance = UNITY_ACCESS_INSTANCED_PROP(_PosiitonNoiseSpaceMode_arr, _PosiitonNoiseSpaceMode);
			float3 lerpResult219 = lerp( temp_output_49_0 , appendResult19_g5 , (float)_PosiitonNoiseSpaceMode_Instance);
			float3 _PositionExtent = float3(1,1,1);
			float3 temp_output_22_0 = ( lerpResult219 * _PositionExtent );
			float _dT_Instance = UNITY_ACCESS_INSTANCED_PROP(_dT_arr, _dT);
			float2 appendResult69 = (float2(floor( v.texcoord.xy.x ) , ( mulTime16 - ( _dT_Instance * _PositionNoiseSpeed_Instance ) )));
			float3 break67 = _PositionNoiseScale_Instance;
			float simplePerlin2D74 = snoise( appendResult69*break67.x );
			float2 appendResult70 = (float2(( floor( v.texcoord.xy.x ) + 0.33 ) , ( mulTime16 - ( _dT_Instance * _PositionNoiseSpeed_Instance ) )));
			float simplePerlin2D72 = snoise( appendResult70*break67.y );
			float2 appendResult68 = (float2(( floor( v.texcoord.xy.x ) + 0.66 ) , ( mulTime16 - ( _dT_Instance * _PositionNoiseSpeed_Instance ) )));
			float simplePerlin2D71 = snoise( appendResult68*break67.z );
			float3 appendResult76 = (float3(simplePerlin2D74 , simplePerlin2D72 , simplePerlin2D71));
			float3 appendResult75 = (float3(UNITY_PI , UNITY_PI , 1.0));
			float3 temp_output_77_0 = ( appendResult76 * appendResult75 );
			float3 break9_g6 = temp_output_77_0;
			float temp_output_10_0_g6 = ( break9_g6.x * 1.0 );
			float temp_output_12_0_g6 = sin( temp_output_10_0_g6 );
			float temp_output_11_0_g6 = ( break9_g6.y * 1.0 );
			float3 appendResult19_g6 = (float3(( break9_g6.z * temp_output_12_0_g6 * cos( temp_output_11_0_g6 ) ) , ( break9_g6.z * temp_output_12_0_g6 * sin( temp_output_11_0_g6 ) ) , ( break9_g6.z * cos( temp_output_10_0_g6 ) )));
			float3 lerpResult221 = lerp( temp_output_77_0 , appendResult19_g6 , (float)_PosiitonNoiseSpaceMode_Instance);
			float3 temp_output_85_0 = ( temp_output_22_0 - ( lerpResult221 * _PositionExtent ) );
			float3 break86 = temp_output_85_0;
			float _RotationOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(_RotationOffset_arr, _RotationOffset);
			float temp_output_260_0 = ( _RotationOffset_Instance * UNITY_PI );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float _WavingLength_Instance = UNITY_ACCESS_INSTANCED_PROP(_WavingLength_arr, _WavingLength);
			float _WavingSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(_WavingSpeed_arr, _WavingSpeed);
			float mulTime200 = _Time.y * _WavingSpeed_Instance;
			float _WavingStrength_Instance = UNITY_ACCESS_INSTANCED_PROP(_WavingStrength_arr, _WavingStrength);
			float _WavingNoiseSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(_WavingNoiseSpeed_arr, _WavingNoiseSpeed);
			float mulTime208 = _Time.y * _WavingNoiseSpeed_Instance;
			float2 appendResult209 = (float2(floor( v.texcoord.xy.x ) , mulTime208));
			float _WavingNoiseScale_Instance = UNITY_ACCESS_INSTANCED_PROP(_WavingNoiseScale_arr, _WavingNoiseScale);
			float simplePerlin2D206 = snoise( appendResult209*_WavingNoiseScale_Instance );
			float clampResult207 = clamp( ( simplePerlin2D206 + 0.0 ) , 0.0 , 1.0 );
			float3 appendResult199 = (float3(0.0 , 0.0 , ( sin( ( ( frac( v.texcoord.xy.x ) * _WavingLength_Instance ) + mulTime200 ) ) * ( _WavingStrength_Instance * clampResult207 ) )));
			float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
			float3 _FishScalePerAxis_Instance = UNITY_ACCESS_INSTANCED_PROP(_FishScalePerAxis_arr, _FishScalePerAxis);
			float2 temp_cast_2 = (floor( v.texcoord.xy.x )).xx;
			float simpleNoise110 = SimpleNoise( temp_cast_2 );
			float _FishRandomizedScaleMin_Instance = UNITY_ACCESS_INSTANCED_PROP(_FishRandomizedScaleMin_arr, _FishRandomizedScaleMin);
			float _FishRandomizedScaleMax_Instance = UNITY_ACCESS_INSTANCED_PROP(_FishRandomizedScaleMax_arr, _FishRandomizedScaleMax);
			float3 appendResult162 = (float3(sin( ( atan2( break86.y , break86.x ) + temp_output_260_0 + ( temp_output_260_0 / 180.0 ) ) ) , 0.0 , cos( ( atan2( break86.y , break86.x ) + temp_output_260_0 + ( temp_output_260_0 / 180.0 ) ) )));
			float3 objToWorldDir163 = mul( unity_ObjectToWorld, float4( appendResult162, 0 ) ).xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult176 = dot( objToWorldDir163 , ase_worldViewDir );
			float3 appendResult175 = (float3(1.0 , 1.0 , ( dotResult176 * -1.0 )));
			float3 rotatedValue88 = RotateAroundAxis( float3( 0,0,0 ), ( ( ( ase_vertex3Pos + appendResult199 ) / ase_objectScale ) * ( _FishScalePerAxis_Instance * (_FishRandomizedScaleMin_Instance + (simpleNoise110 - 0.0) * (_FishRandomizedScaleMax_Instance - _FishRandomizedScaleMin_Instance) / (1.0 - 0.0)) ) * appendResult175 ), _Vector2, ( atan2( break86.y , break86.x ) + temp_output_260_0 + ( temp_output_260_0 / 180.0 ) ) );
			v.vertex.xyz = ( rotatedValue88 + float3(0,0,0) + temp_output_22_0 );
			v.vertex.w = 1;
			float3 ase_vertexNormal = v.normal.xyz;
			float3 rotatedValue182 = RotateAroundAxis( float3( 0,0,0 ), ( ase_vertexNormal * sign( appendResult175 ) ), _Vector2, ( atan2( break86.y , break86.x ) + temp_output_260_0 + ( temp_output_260_0 / 180.0 ) ) );
			v.normal = rotatedValue182;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 _TileScale_Instance = UNITY_ACCESS_INSTANCED_PROP(_TileScale_arr, _TileScale);
			float2 _TileOffset_Instance = UNITY_ACCESS_INSTANCED_PROP(_TileOffset_arr, _TileOffset);
			float _RandomSeed_Instance = UNITY_ACCESS_INSTANCED_PROP(_RandomSeed_arr, _RandomSeed);
			float2 appendResult238 = (float2(floor( i.uv_texcoord.x ) , _RandomSeed_Instance));
			float simpleNoise237 = SimpleNoise( appendResult238 );
			int _Raws_Instance = UNITY_ACCESS_INSTANCED_PROP(_Raws_arr, _Raws);
			int _Cols_Instance = UNITY_ACCESS_INSTANCED_PROP(_Cols_arr, _Cols);
			int _TileCount_Instance = UNITY_ACCESS_INSTANCED_PROP(_TileCount_arr, _TileCount);
			float temp_output_242_0 = ( simpleNoise237 * min( ( _Raws_Instance * _Cols_Instance * simpleNoise237 ) , (float)_TileCount_Instance ) );
			float2 appendResult235 = (float2(floor( ( 0 * 0 ) ) , floor( ( temp_output_242_0 / _Cols_Instance ) )));
			float2 appendResult233 = (float2((float)_Cols_Instance , (float)_Raws_Instance));
			float2 uv_ParallaxMap119_g15 = i.uv_texcoord;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 Offset118_g15 = ( ( tex2D( _ParallaxMap, uv_ParallaxMap119_g15 ).r - 1 ) * ase_worldViewDir.xy * _Parallax ) + ( ( frac( ( ( i.uv_texcoord * _TileScale_Instance ) + _TileOffset_Instance ) ) + appendResult235 ) / appendResult233 );
			#ifdef _PARALLAXMAP
				float2 staticSwitch127_g15 = Offset118_g15;
			#else
				float2 staticSwitch127_g15 = ( ( frac( ( ( i.uv_texcoord * _TileScale_Instance ) + _TileOffset_Instance ) ) + appendResult235 ) / appendResult233 );
			#endif
			#ifdef _NORMALMAP
				float3 staticSwitch143_g15 = UnpackScaleNormal( tex2D( _BumpMap, staticSwitch127_g15 ), _BumpScale );
			#else
				float3 staticSwitch143_g15 = float3(0,0,1);
			#endif
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 uv2_MainTex = i.uv2_texcoord2 * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 lerpResult162_g15 = lerp( uv_MainTex , uv2_MainTex , (float)_UVSetforsecondarytextures);
			float2 uv_DetailMask152_g15 = i.uv_texcoord;
			float3 lerpResult156_g15 = lerp( BlendNormals( UnpackScaleNormal( tex2D( _DetailNormalMap, lerpResult162_g15 ), _DetailNormalMapScale ) , staticSwitch143_g15 ) , staticSwitch143_g15 , tex2D( _DetailMask, uv_DetailMask152_g15 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch138_g15 = lerpResult156_g15;
			#else
				float3 staticSwitch138_g15 = staticSwitch143_g15;
			#endif
			o.Normal = staticSwitch138_g15;
			float4 temp_output_8_0_g15 = ( _Color * tex2D( _MainTex, staticSwitch127_g15 ) );
			float3 temp_output_78_0_g15 = (temp_output_8_0_g15).rgb;
			float4 _DetailAlbedoMap_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_DetailAlbedoMap_ST_arr, _DetailAlbedoMap_ST);
			float2 uv_DetailAlbedoMap = i.uv_texcoord * _DetailAlbedoMap_ST_Instance.xy + _DetailAlbedoMap_ST_Instance.zw;
			float3 lerpResult157_g15 = lerp( (tex2D( _DetailAlbedoMap, uv_DetailAlbedoMap )).rgb , temp_output_78_0_g15 , tex2D( _DetailMask, uv_DetailMask152_g15 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch131_g15 = lerpResult157_g15;
			#else
				float3 staticSwitch131_g15 = temp_output_78_0_g15;
			#endif
			o.Albedo = staticSwitch131_g15;
			#ifdef _EMISSION
				float3 staticSwitch129_g15 = ( (tex2D( _EmissionMap, staticSwitch127_g15 )).rgb * (_EmissionColor).rgb );
			#else
				float3 staticSwitch129_g15 = float3( 0,0,0 );
			#endif
			o.Emission = staticSwitch129_g15;
			o.Metallic = ( tex2D( _MetallicGlossMap, staticSwitch127_g15 ).r * _Metallic );
			o.Smoothness = ( 1.0 - pow( ( tex2D( _SpecGlossMap, staticSwitch127_g15 ).r * _Glossiness ) , _RoughnessCorrection ) );
			o.Occlusion = ( tex2D( _OcclusionMap, staticSwitch127_g15 ).r * _OcclusionStrength );
			o.Alpha = 1;
			clip( temp_output_8_0_g15.a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
0;1087;2346;993;6648.935;1763.71;6.135677;True;True
Node;AmplifyShaderEditor.CommentaryNode;13;-3851.487,204.65;Inherit;False;583.2749;231.8413;Fish ID;5;10;12;32;142;143;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;32;-3835.487,268.6502;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;30;-3824,1152;Inherit;False;InstancedProperty;_PositionNoiseSpeed;Position Noise Speed;40;1;[Header];Create;True;1;Fish Position;0;0;False;0;False;0.02;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;12;-3595.487,284.6501;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-3827.2,1776.074;Inherit;False;InstancedProperty;_dT;dT;44;0;Create;True;0;0;0;False;0;False;0.001;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-3584,1776;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;62;-2992,1664;Inherit;False;1951.673;639.5638;Noise Source;19;80;79;78;77;76;75;74;73;72;71;70;69;68;67;66;65;64;63;221;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;60;-2994.534,821.0763;Inherit;False;1951.673;639.5638;Noise Source;19;52;49;51;19;59;39;15;57;20;14;18;40;43;41;58;55;22;61;219;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RelayNode;10;-3451.487,300.6501;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;16;-3440,1152;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;82;-3360.233,1763.231;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;58;-2944.534,903.0762;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;63;-2944,1744;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-2752.534,999.0766;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.33;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;21;-3632.469,1428.235;Inherit;False;InstancedProperty;_PositionNoiseScale;Position Noise Scale;42;0;Create;True;0;0;0;False;0;False;1,1,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-2752.534,1127.077;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.66;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;65;-2944,1968;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-2752,1840;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.33;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-2752,1968;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.66;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;59;-2944.534,1127.077;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;69;-2560,1712;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;67;-2752,2096;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;40;-2560.534,1127.077;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;68;-2560,1968;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-2560.534,871.0762;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;-2560.534,999.0766;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;57;-2752.534,1255.077;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;70;-2560,1840;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;14;-2352.534,887.0762;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;18;-2352.534,999.0766;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;74;-2352,1728;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;73;-2368,2128;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;71;-2352,1952;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;20;-2352.534,1111.077;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;72;-2352,1840;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;52;-2368,1280;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;75;-2048,2096;Inherit;False;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-2048.534,999.0766;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;76;-2048,1840;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;51;-2048,1248;Inherit;False;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1792,1952;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-1792,1104;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;78;-1607.826,1922.131;Inherit;False;Spherical Coordinate;-1;;6;cdb4d430a0de09a45abc8c247635045d;1,2,0;1;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;23;-3712,1920;Inherit;False;Constant;_PositionExtent;Position Extent;3;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.IntNode;218;-2663.554,1496.837;Inherit;False;InstancedProperty;_PosiitonNoiseSpaceMode;Posiiton Noise Space Mode;41;1;[Enum];Create;True;0;2;Linear;0;Spherical;1;0;False;0;False;1;1;False;0;1;INT;0
Node;AmplifyShaderEditor.FunctionNode;55;-1629.73,1149.8;Inherit;False;Spherical Coordinate;-1;;5;cdb4d430a0de09a45abc8c247635045d;1,2,0;1;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;219;-1363.714,1056.274;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;221;-1351.766,1824.911;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;79;-1496.314,2159.86;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;61;-1568,1280;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-1180.435,1836.505;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1200.348,1100.017;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;158;-712.9823,1252.818;Inherit;False;1270.36;342.7053;Y Angle;11;265;261;259;264;263;262;260;149;87;86;85;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;85;-664.9822,1300.818;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PiNode;263;-368.009,1522.784;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;217;-988.0107,-724.9394;Inherit;False;1668.176;812.7097;Waving;21;212;208;205;213;216;209;206;195;203;215;214;194;200;201;193;210;196;199;197;207;204;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;264;-591.009,1479.784;Inherit;False;InstancedProperty;_RotationOffset;Rotation Offset;43;0;Create;True;0;0;0;False;0;False;0;0;-180;180;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;86;-456.9818,1375.248;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;260;-205.009,1437.784;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;254;1629.57,-464.3837;Inherit;False;2376.28;800.6337;Tiling;23;238;237;231;240;244;253;250;239;230;233;242;241;236;245;248;243;235;251;249;255;256;257;258;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-938.0107,-220.0702;Inherit;False;InstancedProperty;_WavingNoiseSpeed;Waving Noise Speed;48;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;262;-71.00903,1520.784;Inherit;False;Constant;_Float0;Float 0;22;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;87;-296.9817,1300.818;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;261;48.83479,1434.893;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;208;-649.0107,-238.0702;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;239;1679.57,210.5841;Inherit;False;InstancedProperty;_RandomSeed;Random Seed;37;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;142;-3584.698,360.5841;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;205;-840.6573,-338.9387;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;238;1946.121,109.6563;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;259;240.4781,1312.097;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;143;-3468.473,367.674;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;213;-586.0106,-134.0702;Inherit;False;InstancedProperty;_WavingNoiseScale;Waving Noise Scale;49;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;209;-446.0105,-331.0702;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;203;-664.6574,-466.9388;Inherit;False;InstancedProperty;_WavingSpeed;Waving Speed;47;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;206;-243.6571,-299.9386;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;265;336.6731,1464.028;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;231;2244.809,-73.52419;Inherit;False;InstancedProperty;_Cols;Cols;35;0;Create;True;0;0;0;False;0;False;1;1;False;0;1;INT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;237;2234.121,93.65635;Inherit;False;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;230;2244.809,-153.5242;Inherit;False;InstancedProperty;_Raws;Raws;34;1;[Header];Create;True;1;Tiling;0;0;False;0;False;1;1;False;0;1;INT;0
Node;AmplifyShaderEditor.CommentaryNode;171;135.4708,1617.05;Inherit;False;1388;601.8911;Flip Backface;11;161;159;162;163;170;174;175;176;177;178;181;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;195;-680.6574,-578.9393;Inherit;False;InstancedProperty;_WavingLength;Waving Length;46;0;Create;True;0;0;0;False;0;False;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;204;-932.0487,-674.7218;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-328.6572,-674.9393;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;214;-39.0342,-180.2246;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;240;2250.121,13.65635;Inherit;False;InstancedProperty;_TileCount;Tile Count;36;0;Create;True;0;0;0;False;0;False;1;1;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleTimeNode;200;-350.6544,-491.6982;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;159;185.4707,1667.05;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;236;2514.761,180.25;Inherit;False;3;3;0;INT;0;False;1;INT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;161;185.4707,1747.05;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;185;-1544.033,190.026;Inherit;False;1151.647;499.75;Fish Local Scale;8;184;109;183;111;54;113;112;110;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMinOpNode;241;2684.401,104.5952;Inherit;False;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;201;-103.6543,-560.6986;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;197;-9.933631,-344.3145;Inherit;False;InstancedProperty;_WavingStrength;Waving Strength;45;1;[Header];Create;True;1;Fish Waving;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;162;361.4707,1683.05;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;207;149.4397,-144.0176;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;253;1976,-433;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;163;521.4707,1683.05;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;174;537.8945,1868.124;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;242;2871.865,-6.670813;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;193;39.3427,-626.9394;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;256;1988.007,-180.333;Inherit;False;InstancedProperty;_TileScale;Tile Scale;38;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RelayNode;109;-1494.033,246.8167;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;210;220.1346,-369.3292;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;110;-1285.73,240.026;Inherit;False;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;176;780.2593,1801.209;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;244;3083.121,97.65635;Inherit;False;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;248;3060.587,-98.33414;Inherit;False;Fract Mod;-1;;17;8f30360dc4dbc404a80849761a676932;0;2;1;OBJECT;0;False;3;OBJECT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;255;2463,-388;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-1514.811,350.9246;Inherit;False;InstancedProperty;_FishRandomizedScaleMin;Fish Randomized Scale Min;52;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;186;274.4008,146.2053;Inherit;False;822.6082;387.9588;Fish Vertex Position;4;115;114;24;198;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;258;2045.007,-310.333;Inherit;False;InstancedProperty;_TileOffset;Tile Offset;39;0;Create;True;0;0;0;True;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;113;-1517.277,444.6351;Inherit;False;InstancedProperty;_FishRandomizedScaleMax;Fish Randomized Scale Max;53;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;286.6905,-541.3428;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;924.8543,1801.209;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;243;3284.764,-96.5313;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;111;-1068.654,290.4977;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;54;-1472,545.1014;Inherit;False;InstancedProperty;_FishScalePerAxis;Fish Scale Per Axis;51;1;[Header];Create;True;1;Fish Scale;0;0;False;0;False;1,1,1;1,0.5,0.2;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;24;324.4009,196.2055;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;199;513.1654,-494.2107;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FloorOpNode;245;3279.053,92.16129;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;257;2613.007,-336.333;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;175;1085.685,1746.793;Inherit;False;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;235;3450.626,-8.63983;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ObjectScaleNode;114;333.6636,347.5671;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;-768,400;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;198;745.8242,196.8999;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FractNode;250;2784,-384;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RelayNode;184;-579.241,332.9082;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;190;1658.639,773.0458;Inherit;False;216.3618;335.2633;Scale;2;173;53;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;115;953.6843,224.5179;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;189;2124.398,783.3616;Inherit;False;984.3821;427.5447;Rotate Y;4;182;88;89;188;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SignOpNode;177;1244.855,1849.209;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;233;2528.01,-184.9205;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;251;3627.813,-150.4953;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RelayNode;170;1404.854,1689.209;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;172;671.032,1295.347;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;249;3848.85,-320.2929;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;89;2310.811,833.3616;Inherit;False;Constant;_Vector2;Vector 2;3;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RelayNode;178;1404.854,1833.209;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;188;2174.398,1080.09;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;1708.639,823.0458;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;191;5235.147,1473.656;Inherit;False;205;206;Translate;1;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;173;1699.884,960.1708;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;88;2777.78,851.4594;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;226;4872.445,744.553;Inherit;False;EsnyaPBR;0;;15;da1a8a67aa976ee4a9419c7e6f582eff;2,175,0,179,1;1;180;FLOAT2;0,0;False;11;FLOAT3;0;FLOAT3;34;FLOAT3;42;FLOAT;30;FLOAT;17;FLOAT;44;FLOAT3;89;FLOAT3;96;FLOAT;84;FLOAT;14;FLOAT3;115
Node;AmplifyShaderEditor.SimpleAddOpNode;2;5285.147,1523.656;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;215;-212.7047,-76.84921;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;182;2775.32,1031.906;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;216;-611.0445,-27.22898;Inherit;False;InstancedProperty;_WavingBySpeed;Waving By Speed;50;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;149;-472.1605,1301.278;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;56;5883.735,1103.515;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;EsnyaShaders/Osakana Shader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;12;0;32;1
WireConnection;83;0;84;0
WireConnection;83;1;30;0
WireConnection;10;0;12;0
WireConnection;16;0;30;0
WireConnection;82;0;16;0
WireConnection;82;1;83;0
WireConnection;58;0;10;0
WireConnection;63;0;10;0
WireConnection;41;0;58;0
WireConnection;43;0;58;0
WireConnection;65;0;82;0
WireConnection;66;0;63;0
WireConnection;64;0;63;0
WireConnection;59;0;16;0
WireConnection;69;0;63;0
WireConnection;69;1;65;0
WireConnection;67;0;21;0
WireConnection;40;0;43;0
WireConnection;40;1;59;0
WireConnection;68;0;64;0
WireConnection;68;1;65;0
WireConnection;15;0;58;0
WireConnection;15;1;59;0
WireConnection;39;0;41;0
WireConnection;39;1;59;0
WireConnection;57;0;21;0
WireConnection;70;0;66;0
WireConnection;70;1;65;0
WireConnection;14;0;15;0
WireConnection;14;1;57;0
WireConnection;18;0;39;0
WireConnection;18;1;57;1
WireConnection;74;0;69;0
WireConnection;74;1;67;0
WireConnection;71;0;68;0
WireConnection;71;1;67;2
WireConnection;20;0;40;0
WireConnection;20;1;57;2
WireConnection;72;0;70;0
WireConnection;72;1;67;1
WireConnection;75;0;73;0
WireConnection;75;1;73;0
WireConnection;19;0;14;0
WireConnection;19;1;18;0
WireConnection;19;2;20;0
WireConnection;76;0;74;0
WireConnection;76;1;72;0
WireConnection;76;2;71;0
WireConnection;51;0;52;0
WireConnection;51;1;52;0
WireConnection;77;0;76;0
WireConnection;77;1;75;0
WireConnection;49;0;19;0
WireConnection;49;1;51;0
WireConnection;78;1;77;0
WireConnection;55;1;49;0
WireConnection;219;0;49;0
WireConnection;219;1;55;0
WireConnection;219;2;218;0
WireConnection;221;0;77;0
WireConnection;221;1;78;0
WireConnection;221;2;218;0
WireConnection;79;0;23;0
WireConnection;61;0;23;0
WireConnection;80;0;221;0
WireConnection;80;1;79;0
WireConnection;22;0;219;0
WireConnection;22;1;61;0
WireConnection;85;0;22;0
WireConnection;85;1;80;0
WireConnection;86;0;85;0
WireConnection;260;0;264;0
WireConnection;260;1;263;0
WireConnection;87;0;86;1
WireConnection;87;1;86;0
WireConnection;261;0;260;0
WireConnection;261;1;262;0
WireConnection;208;0;212;0
WireConnection;142;0;32;1
WireConnection;205;0;10;0
WireConnection;238;0;10;0
WireConnection;238;1;239;0
WireConnection;259;0;87;0
WireConnection;259;1;260;0
WireConnection;259;2;261;0
WireConnection;143;0;142;0
WireConnection;209;0;205;0
WireConnection;209;1;208;0
WireConnection;206;0;209;0
WireConnection;206;1;213;0
WireConnection;265;0;259;0
WireConnection;237;0;238;0
WireConnection;204;0;143;0
WireConnection;194;0;204;0
WireConnection;194;1;195;0
WireConnection;214;0;206;0
WireConnection;200;0;203;0
WireConnection;159;0;265;0
WireConnection;236;0;230;0
WireConnection;236;1;231;0
WireConnection;236;2;237;0
WireConnection;161;0;265;0
WireConnection;241;0;236;0
WireConnection;241;1;240;0
WireConnection;201;0;194;0
WireConnection;201;1;200;0
WireConnection;162;0;159;0
WireConnection;162;2;161;0
WireConnection;207;0;214;0
WireConnection;163;0;162;0
WireConnection;242;0;237;0
WireConnection;242;1;241;0
WireConnection;193;0;201;0
WireConnection;109;0;10;0
WireConnection;210;0;197;0
WireConnection;210;1;207;0
WireConnection;110;0;109;0
WireConnection;176;0;163;0
WireConnection;176;1;174;0
WireConnection;244;0;242;0
WireConnection;244;1;231;0
WireConnection;248;1;242;0
WireConnection;248;3;231;0
WireConnection;255;0;253;0
WireConnection;255;1;256;0
WireConnection;196;0;193;0
WireConnection;196;1;210;0
WireConnection;181;0;176;0
WireConnection;243;0;248;0
WireConnection;111;0;110;0
WireConnection;111;3;112;0
WireConnection;111;4;113;0
WireConnection;199;2;196;0
WireConnection;245;0;244;0
WireConnection;257;0;255;0
WireConnection;257;1;258;0
WireConnection;175;2;181;0
WireConnection;235;0;243;0
WireConnection;235;1;245;0
WireConnection;183;0;54;0
WireConnection;183;1;111;0
WireConnection;198;0;24;0
WireConnection;198;1;199;0
WireConnection;250;0;257;0
WireConnection;184;0;183;0
WireConnection;115;0;198;0
WireConnection;115;1;114;0
WireConnection;177;0;175;0
WireConnection;233;0;231;0
WireConnection;233;1;230;0
WireConnection;251;0;250;0
WireConnection;251;1;235;0
WireConnection;170;0;175;0
WireConnection;249;0;251;0
WireConnection;249;1;233;0
WireConnection;178;0;177;0
WireConnection;188;0;265;0
WireConnection;53;0;115;0
WireConnection;53;1;184;0
WireConnection;53;2;170;0
WireConnection;173;0;172;0
WireConnection;173;1;178;0
WireConnection;88;0;89;0
WireConnection;88;1;188;0
WireConnection;88;3;53;0
WireConnection;226;180;249;0
WireConnection;2;0;88;0
WireConnection;2;1;226;115
WireConnection;2;2;22;0
WireConnection;215;0;149;0
WireConnection;215;1;216;0
WireConnection;182;0;89;0
WireConnection;182;1;188;0
WireConnection;182;3;173;0
WireConnection;149;0;85;0
WireConnection;56;0;226;0
WireConnection;56;1;226;34
WireConnection;56;2;226;42
WireConnection;56;3;226;30
WireConnection;56;4;226;17
WireConnection;56;5;226;44
WireConnection;56;10;226;14
WireConnection;56;11;2;0
WireConnection;56;12;182;0
ASEEND*/
//CHKSM=659AB982297F6FA53ACACBB2E453A479AD903E90