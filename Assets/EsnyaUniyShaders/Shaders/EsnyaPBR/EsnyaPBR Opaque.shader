// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Esnya PBR/Opaque"
{
	Properties
	{
		[Header(PBR Material)][Header(Base Color)]_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		[NoScaleOffset][VisibleIf(_DETAIL_MULX2)]_DetailMask("Detail Mask", 2D) = "white" {}
		[Header(Roughness)][NoScaleOffset]_SpecGlossMap("Roughness Map", 2D) = "white" {}
		_Glossiness("Roughness", Range( 0 , 1)) = 1
		_RoughnessCorrection("Roughness Correction", Float) = 0.45
		[Toggle(_GeometricSpecularAA)] _GeometricSpecularAA1("Geometric Specular AA", Float) = 0
		[Header(Metallic)][NoScaleOffset]_MetallicGlossMap("Metallic Map", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 1
		[Header(Normal)][Toggle(_NORMALMAP)] _NORMALMAP("Use Normal Map", Float) = 0
		[NoScaleOffset][Normal][EsnyaFactory.VisibleIf(_NORMALMAP)]_BumpMap("Normal Map", 2D) = "bump" {}
		[VisibleIf(_NORMALMAP)]_BumpScale("Normal Scale", Float) = 1
		[VisibleIf(_NORMALMAP)][Toggle(_NEAGTENORMALG_ON)] _NeagteNormalG("Neagte Normal G", Float) = 0
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
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull [_CullMode]
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _ZSHIFT_ON
		#pragma shader_feature _NEAGTENORMALG_ON
		#pragma shader_feature _DETAIL_MULX2
		#pragma shader_feature _NORMALMAP
		#pragma shader_feature _PARALLAXMAP
		#pragma shader_feature _EMISSION
		#pragma shader_feature _GeometricSpecularAA
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float2 uv2_texcoord2;
			float3 worldNormal;
			INTERNAL_DATA
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
			float3 worldToObjDir105_g5 = mul( unity_WorldToObject, float4( ase_worldViewDir, 0 ) ).xyz;
			float3 objToWorld110_g5 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult109_g5 = (float2(( objToWorld110_g5.x + objToWorld110_g5.y ) , ( objToWorld110_g5.y + objToWorld110_g5.z )));
			float simpleNoise106_g5 = SimpleNoise( appendResult109_g5*1000.0 );
			simpleNoise106_g5 = simpleNoise106_g5*2 - 1;
			#ifdef _ZSHIFT_ON
				float3 staticSwitch112_g5 = ( worldToObjDir105_g5 * simpleNoise106_g5 * _ZShiftScale );
			#else
				float3 staticSwitch112_g5 = float3(0,0,0);
			#endif
			v.vertex.xyz += staticSwitch112_g5;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 uv_ParallaxMap119_g5 = i.uv_texcoord;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 Offset118_g5 = ( ( tex2D( _ParallaxMap, uv_ParallaxMap119_g5 ).r - 1 ) * ase_worldViewDir.xy * _Parallax ) + uv_MainTex;
			#ifdef _PARALLAXMAP
				float2 staticSwitch127_g5 = Offset118_g5;
			#else
				float2 staticSwitch127_g5 = uv_MainTex;
			#endif
			#ifdef _NORMALMAP
				float3 staticSwitch143_g5 = UnpackScaleNormal( tex2D( _BumpMap, staticSwitch127_g5 ), _BumpScale );
			#else
				float3 staticSwitch143_g5 = float3(0,0,1);
			#endif
			float2 uv2_MainTex = i.uv2_texcoord2 * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 lerpResult162_g5 = lerp( uv_MainTex , uv2_MainTex , (float)_UVSetforsecondarytextures);
			float2 uv_DetailMask152_g5 = i.uv_texcoord;
			float3 lerpResult156_g5 = lerp( BlendNormals( UnpackScaleNormal( tex2D( _DetailNormalMap, lerpResult162_g5 ), _DetailNormalMapScale ) , staticSwitch143_g5 ) , staticSwitch143_g5 , tex2D( _DetailMask, uv_DetailMask152_g5 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch138_g5 = lerpResult156_g5;
			#else
				float3 staticSwitch138_g5 = staticSwitch143_g5;
			#endif
			#ifdef _NEAGTENORMALG_ON
				float3 staticSwitch181_g5 = ( staticSwitch138_g5 * float3(1,-1,1) );
			#else
				float3 staticSwitch181_g5 = staticSwitch138_g5;
			#endif
			o.Normal = staticSwitch181_g5;
			float4 temp_output_8_0_g5 = ( _Color * tex2D( _MainTex, staticSwitch127_g5 ) );
			float3 temp_output_78_0_g5 = (temp_output_8_0_g5).rgb;
			float2 uv_DetailAlbedoMap = i.uv_texcoord * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
			float3 lerpResult157_g5 = lerp( (tex2D( _DetailAlbedoMap, uv_DetailAlbedoMap )).rgb , temp_output_78_0_g5 , tex2D( _DetailMask, uv_DetailMask152_g5 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch131_g5 = lerpResult157_g5;
			#else
				float3 staticSwitch131_g5 = temp_output_78_0_g5;
			#endif
			o.Albedo = staticSwitch131_g5;
			#ifdef _EMISSION
				float3 staticSwitch129_g5 = ( (tex2D( _EmissionMap, staticSwitch127_g5 )).rgb * (_EmissionColor).rgb );
			#else
				float3 staticSwitch129_g5 = float3( 0,0,0 );
			#endif
			o.Emission = staticSwitch129_g5;
			o.Metallic = ( tex2D( _MetallicGlossMap, staticSwitch127_g5 ).r * _Metallic );
			float3 newWorldNormal3_g6 = (WorldNormalVector( i , staticSwitch181_g5 ));
			float3 temp_output_6_0_g6 = ddx( newWorldNormal3_g6 );
			float dotResult7_g6 = dot( temp_output_6_0_g6 , temp_output_6_0_g6 );
			float3 temp_output_10_0_g6 = ddy( newWorldNormal3_g6 );
			float dotResult12_g6 = dot( temp_output_10_0_g6 , temp_output_10_0_g6 );
			#ifdef _GeometricSpecularAA
				float staticSwitch187_g5 = ( 1.0 - pow( saturate( max( dotResult7_g6 , dotResult12_g6 ) ) , 0.333 ) );
			#else
				float staticSwitch187_g5 = 1.0;
			#endif
			o.Smoothness = min( ( 1.0 - pow( ( tex2D( _SpecGlossMap, staticSwitch127_g5 ).r * _Glossiness ) , _RoughnessCorrection ) ) , staticSwitch187_g5 );
			o.Occlusion = ( tex2D( _OcclusionMap, staticSwitch127_g5 ).r * _OcclusionStrength );
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.zw = customInputData.uv2_texcoord2;
				o.customPack1.zw = v.texcoord1;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.uv2_texcoord2 = IN.customPack1.zw;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "EsnyaFactory.EsnyaPBRGUI"
}
/*ASEBEGIN
Version=18909
0;1191;2599;889;1940.279;323.8434;1;True;True
Node;AmplifyShaderEditor.IntNode;4;-640,128;Inherit;False;Property;_CullMode;Cull Mode;35;2;[Header];[Enum];Create;False;1;Shader Options;0;1;CullMode;True;0;False;2;0;False;0;1;INT;0
Node;AmplifyShaderEditor.FunctionNode;128;-640,-256;Inherit;False;EsnyaPBR;0;;5;d7448cd6078718a4b92322da44cf5771;2,175,1,179,0;1;180;FLOAT2;0,0;False;11;FLOAT3;0;FLOAT3;34;FLOAT3;42;FLOAT;30;FLOAT;17;FLOAT;44;FLOAT3;89;FLOAT3;96;FLOAT;84;FLOAT;14;FLOAT3;115
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-256,-256;Float;False;True;-1;2;EsnyaFactory.EsnyaPBRGUI;0;0;Standard;Esnya PBR/Opaque;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;4;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;0;128;0
WireConnection;0;1;128;34
WireConnection;0;2;128;42
WireConnection;0;3;128;30
WireConnection;0;4;128;17
WireConnection;0;5;128;44
WireConnection;0;11;128;115
ASEEND*/
//CHKSM=DD45B0DA063BCABB0CA80C976DA455A85F7A8E79