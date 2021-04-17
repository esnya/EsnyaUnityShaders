// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Esnya PBR/Cutout"
{
	Properties
	{
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
		[Header(Z Shift)][Toggle(_ZSHIFT_ON)] _ZShift("Z Shift", Float) = 0
		[VisibleIf(_ZSHIFT_ON)]_ZShiftScale("Z Shift Scale", Float) = 0.005
		[Header(Shader Options)][Enum(CullMode)]_CullMode("Cull Mode", Int) = 2
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull [_CullMode]
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma shader_feature _ZSHIFT_ON
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

		uniform int _CullMode;
		uniform float _ZShiftScale;
		uniform sampler2D _BumpMap;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _ParallaxMap;
		uniform float _Parallax;
		uniform float _BumpScale;
		uniform sampler2D _DetailNormalMap;
		uniform int _UVSetforsecondarytextures;
		uniform float _DetailNormalMapScale;
		uniform sampler2D _DetailMask;
		uniform float4 _Color;
		uniform sampler2D _DetailAlbedoMap;
		uniform float4 _DetailAlbedoMap_ST;
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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 worldToObjDir105_g8 = mul( unity_WorldToObject, float4( ase_worldViewDir, 0 ) ).xyz;
			float3 objToWorld110_g8 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult109_g8 = (float2(( objToWorld110_g8.x + objToWorld110_g8.y ) , ( objToWorld110_g8.y + objToWorld110_g8.z )));
			float simpleNoise106_g8 = SimpleNoise( appendResult109_g8*1000.0 );
			simpleNoise106_g8 = simpleNoise106_g8*2 - 1;
			#ifdef _ZSHIFT_ON
				float3 staticSwitch112_g8 = ( worldToObjDir105_g8 * simpleNoise106_g8 * _ZShiftScale );
			#else
				float3 staticSwitch112_g8 = float3(0,0,0);
			#endif
			v.vertex.xyz += staticSwitch112_g8;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 uv_ParallaxMap119_g8 = i.uv_texcoord;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 Offset118_g8 = ( ( tex2D( _ParallaxMap, uv_ParallaxMap119_g8 ).r - 1 ) * ase_worldViewDir.xy * _Parallax ) + uv_MainTex;
			#ifdef _PARALLAXMAP
				float2 staticSwitch127_g8 = Offset118_g8;
			#else
				float2 staticSwitch127_g8 = uv_MainTex;
			#endif
			#ifdef _NORMALMAP
				float3 staticSwitch143_g8 = UnpackScaleNormal( tex2D( _BumpMap, staticSwitch127_g8 ), _BumpScale );
			#else
				float3 staticSwitch143_g8 = float3(0,0,1);
			#endif
			float2 uv2_MainTex = i.uv2_texcoord2 * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 lerpResult162_g8 = lerp( uv_MainTex , uv2_MainTex , (float)_UVSetforsecondarytextures);
			float2 uv_DetailMask152_g8 = i.uv_texcoord;
			float3 lerpResult156_g8 = lerp( BlendNormals( UnpackScaleNormal( tex2D( _DetailNormalMap, lerpResult162_g8 ), _DetailNormalMapScale ) , staticSwitch143_g8 ) , staticSwitch143_g8 , tex2D( _DetailMask, uv_DetailMask152_g8 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch138_g8 = lerpResult156_g8;
			#else
				float3 staticSwitch138_g8 = staticSwitch143_g8;
			#endif
			o.Normal = staticSwitch138_g8;
			float4 temp_output_8_0_g8 = ( _Color * tex2D( _MainTex, staticSwitch127_g8 ) );
			float3 temp_output_78_0_g8 = (temp_output_8_0_g8).rgb;
			float2 uv_DetailAlbedoMap = i.uv_texcoord * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
			float3 lerpResult157_g8 = lerp( (tex2D( _DetailAlbedoMap, uv_DetailAlbedoMap )).rgb , temp_output_78_0_g8 , tex2D( _DetailMask, uv_DetailMask152_g8 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch131_g8 = lerpResult157_g8;
			#else
				float3 staticSwitch131_g8 = temp_output_78_0_g8;
			#endif
			o.Albedo = staticSwitch131_g8;
			#ifdef _EMISSION
				float3 staticSwitch129_g8 = ( (tex2D( _EmissionMap, staticSwitch127_g8 )).rgb * (_EmissionColor).rgb );
			#else
				float3 staticSwitch129_g8 = float3( 0,0,0 );
			#endif
			o.Emission = staticSwitch129_g8;
			o.Metallic = ( tex2D( _MetallicGlossMap, staticSwitch127_g8 ).r * _Metallic );
			o.Smoothness = ( 1.0 - pow( ( tex2D( _SpecGlossMap, staticSwitch127_g8 ).r * _Glossiness ) , _RoughnessCorrection ) );
			o.Occlusion = ( tex2D( _OcclusionMap, staticSwitch127_g8 ).r * _OcclusionStrength );
			o.Alpha = 1;
			clip( temp_output_8_0_g8.a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "EsnyaFactory.EsnyaPBRGUI"
}
/*ASEBEGIN
Version=18712
0;985;2346;1095;1562.548;363.0095;1;True;True
Node;AmplifyShaderEditor.FunctionNode;10;-512,-128;Inherit;False;PBR;0;;8;da1a8a67aa976ee4a9419c7e6f582eff;0;0;11;FLOAT3;0;FLOAT3;34;FLOAT3;42;FLOAT;30;FLOAT;17;FLOAT;44;FLOAT3;89;FLOAT3;96;FLOAT;84;FLOAT;14;FLOAT3;115
Node;AmplifyShaderEditor.IntNode;4;-515,235;Inherit;False;Property;_CullMode;Cull Mode;33;2;[Header];[Enum];Create;False;1;Shader Options;0;1;CullMode;True;0;False;2;0;False;0;1;INT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,-128;Float;False;True;-1;2;EsnyaFactory.EsnyaPBRGUI;0;0;Standard;Esnya PBR/Cutout;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;34;-1;-1;-1;0;False;0;0;True;4;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;0;10;0
WireConnection;0;1;10;34
WireConnection;0;2;10;42
WireConnection;0;3;10;30
WireConnection;0;4;10;17
WireConnection;0;5;10;44
WireConnection;0;10;10;14
WireConnection;0;11;10;115
ASEEND*/
//CHKSM=F7CC52D4096B12EF3DC54D9B9DEC4269E222D632