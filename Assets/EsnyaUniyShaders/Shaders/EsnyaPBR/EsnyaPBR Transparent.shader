// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Esnya PBR/Transparent"
{
	Properties
	{
		[Header(PBR Material)][Header(Base Color)]_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		[Header(Metallic)][NoScaleOffset]_MetallicGlossMap("Metallic Map", 2D) = "white" {}
		[Toggle(_PACKEDMASK_ON)] _PackedMask("Packed Mask (Metallic R/G/B/A will be mapped Metallic/AO/Height/Roughness or Smoothness)", Float) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 1
		[Header(Roughness  Smoothness)][Toggle(_METALLICGLOSSMAP)] _METALLICGLOSSMAP("Smoothness Setup", Float) = 0
		[NoScaleOffset][EsnyaFactory.HideIf(_METALLICGLOSSMAP, _PACKEDMASK_ON)]_SpecGlossMap("Roughness Map", 2D) = "white" {}
		[Enum(Metallic Alpha,0,Albedo Alpha,1)]_SmoothnessTextureChannel("Smoothness Texture Channel", Float) = 0
		_Glossiness("Roughness / Smoothness", Range( 0 , 1)) = 1
		_RoughnessSmoothnessCorrection("Roughness / Smoothness Correction", Float) = 0.45
		[Toggle(_GeometricSpecularAA)] _GeometricSpecularAA("Geometric Specular AA", Float) = 0
		[Header(Normal)][Toggle(_NORMALMAP)] _NORMALMAP("Use Normal Map", Float) = 0
		[NoScaleOffset][Normal][EsnyaFactory.VisibleIf(_NORMALMAP)]_BumpMap("Normal Map", 2D) = "bump" {}
		[VisibleIf(_NORMALMAP)]_BumpScale("Normal Scale", Float) = 1
		[VisibleIf(_NORMALMAP)][Toggle(_NEAGTENORMALG_ON)] _NeagteNormalG("Neagte Normal G", Float) = 0
		[Header(Emission)][Toggle(_EMISSION)] _EMISSION("Use Emission", Float) = 0
		[HDR][NoScaleOffset][VisibleIf(_EMISSION)]_EmissionMap("EmissionMap", 2D) = "white" {}
		[HDR][VisibleIf(_EMISSION)]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		[Header(Occlusion)][NoScaleOffset][EsnyaFactory.HideIf(_PACKEDMASK_ON)]_OcclusionMap("Occlusion", 2D) = "white" {}
		_OcclusionStrength("Occlusion Strength", Float) = 1
		[Header(Height Map)][Toggle(_PARALLAXMAP)] _PARALLAXMAP("Use Height Map", Float) = 0
		[NoScaleOffset][VisibleIf(_PARALLAXMAP)][EsnyaFactory.HideIf(_PACKEDMASK_ON)]_ParallaxMap("Height Map", 2D) = "black" {}
		[VisibleIf(_PARALLAXMAP)]_Parallax("Height Map Scale", Range( 0.005 , 0.08)) = 0.005
		[Header(Use Detail Map)][Toggle(_DETAIL_MULX2)] _DETAIL_MULX2("Use Detail Maps", Float) = 0
		[NoScaleOffset][VisibleIf(_DETAIL_MULX2)]_DetailMask("Detail Mask", 2D) = "white" {}
		[VisibleIf(_DETAIL_MULX2)]_DetailAlbedoMap("Detail Albedo", 2D) = "white" {}
		[NoScaleOffset][Normal][VisibleIf(_DETAIL_MULX2)]_DetailNormalMap("Detail Normal Map", 2D) = "bump" {}
		[VisibleIf(_DETAIL_MULX2)]_DetailNormalMapScale("Detail Normal Map Scale", Float) = 1
		[Enum(UV1,0,UV2,1)]_UVSetforsecondarytextures("UV Set for secondary textures", Int) = 0
		[Header(Z Shift)][Toggle(_ZSHIFT_ON)] _ZShift("Z Shift", Float) = 0
		[VisibleIf(_ZSHIFT_ON)]_ZShiftScale("Z Shift Scale", Float) = 0.005
		_CullMode("CullMode", Int) = 2
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#pragma shader_feature _ZSHIFT_ON
		#pragma shader_feature _NEAGTENORMALG_ON
		#pragma shader_feature _DETAIL_MULX2
		#pragma shader_feature _NORMALMAP
		#pragma shader_feature _PARALLAXMAP
		#pragma shader_feature _PACKEDMASK_ON
		#pragma shader_feature _EMISSION
		#pragma shader_feature _METALLICGLOSSMAP
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

		uniform float _ZShiftScale;
		uniform sampler2D _BumpMap;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _ParallaxMap;
		uniform sampler2D _MetallicGlossMap;
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
		uniform float _Metallic;
		uniform sampler2D _SpecGlossMap;
		uniform float _SmoothnessTextureChannel;
		uniform float _Glossiness;
		uniform float _RoughnessSmoothnessCorrection;
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
			float3 worldToObjDir105_g3 = mul( unity_WorldToObject, float4( ase_worldViewDir, 0 ) ).xyz;
			float3 objToWorld110_g3 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult109_g3 = (float2(( objToWorld110_g3.x + objToWorld110_g3.y ) , ( objToWorld110_g3.y + objToWorld110_g3.z )));
			float simpleNoise106_g3 = SimpleNoise( appendResult109_g3*1000.0 );
			simpleNoise106_g3 = simpleNoise106_g3*2 - 1;
			#ifdef _ZSHIFT_ON
				float3 staticSwitch112_g3 = ( worldToObjDir105_g3 * simpleNoise106_g3 * _ZShiftScale );
			#else
				float3 staticSwitch112_g3 = float3(0,0,0);
			#endif
			v.vertex.xyz += staticSwitch112_g3;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 uv_ParallaxMap119_g3 = i.uv_texcoord;
			float2 uv_MetallicGlossMap203_g3 = i.uv_texcoord;
			#ifdef _PACKEDMASK_ON
				float staticSwitch199_g3 = tex2D( _MetallicGlossMap, uv_MetallicGlossMap203_g3 ).b;
			#else
				float staticSwitch199_g3 = tex2D( _ParallaxMap, uv_ParallaxMap119_g3 ).r;
			#endif
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 Offset118_g3 = ( ( staticSwitch199_g3 - 1 ) * ase_worldViewDir.xy * _Parallax ) + uv_MainTex;
			#ifdef _PARALLAXMAP
				float2 staticSwitch127_g3 = Offset118_g3;
			#else
				float2 staticSwitch127_g3 = uv_MainTex;
			#endif
			#ifdef _NORMALMAP
				float3 staticSwitch143_g3 = UnpackScaleNormal( tex2D( _BumpMap, staticSwitch127_g3 ), _BumpScale );
			#else
				float3 staticSwitch143_g3 = float3(0,0,1);
			#endif
			float2 uv2_MainTex = i.uv2_texcoord2 * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 lerpResult162_g3 = lerp( uv_MainTex , uv2_MainTex , (float)_UVSetforsecondarytextures);
			float2 uv_DetailMask152_g3 = i.uv_texcoord;
			float3 lerpResult156_g3 = lerp( BlendNormals( UnpackScaleNormal( tex2D( _DetailNormalMap, lerpResult162_g3 ), _DetailNormalMapScale ) , staticSwitch143_g3 ) , staticSwitch143_g3 , tex2D( _DetailMask, uv_DetailMask152_g3 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch138_g3 = lerpResult156_g3;
			#else
				float3 staticSwitch138_g3 = staticSwitch143_g3;
			#endif
			#ifdef _NEAGTENORMALG_ON
				float3 staticSwitch181_g3 = ( staticSwitch138_g3 * float3(1,-1,1) );
			#else
				float3 staticSwitch181_g3 = staticSwitch138_g3;
			#endif
			o.Normal = staticSwitch181_g3;
			float4 temp_output_8_0_g3 = ( _Color * tex2D( _MainTex, staticSwitch127_g3 ) );
			float3 temp_output_78_0_g3 = (temp_output_8_0_g3).rgb;
			float2 uv_DetailAlbedoMap = i.uv_texcoord * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
			float3 lerpResult157_g3 = lerp( (tex2D( _DetailAlbedoMap, uv_DetailAlbedoMap )).rgb , temp_output_78_0_g3 , tex2D( _DetailMask, uv_DetailMask152_g3 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch131_g3 = lerpResult157_g3;
			#else
				float3 staticSwitch131_g3 = temp_output_78_0_g3;
			#endif
			o.Albedo = staticSwitch131_g3;
			#ifdef _EMISSION
				float3 staticSwitch129_g3 = ( (tex2D( _EmissionMap, staticSwitch127_g3 )).rgb * (_EmissionColor).rgb );
			#else
				float3 staticSwitch129_g3 = float3( 0,0,0 );
			#endif
			o.Emission = staticSwitch129_g3;
			o.Metallic = ( tex2D( _MetallicGlossMap, staticSwitch127_g3 ).r * _Metallic );
			float2 uv_MetallicGlossMap206_g3 = i.uv_texcoord;
			float lerpResult191_g3 = lerp( tex2D( _MetallicGlossMap, uv_MetallicGlossMap206_g3 ).a , tex2D( _MainTex, uv_MainTex ).a , _SmoothnessTextureChannel);
			#ifdef _PACKEDMASK_ON
				float staticSwitch207_g3 = lerpResult191_g3;
			#else
				float staticSwitch207_g3 = tex2D( _SpecGlossMap, staticSwitch127_g3 ).r;
			#endif
			#ifdef _METALLICGLOSSMAP
				float staticSwitch189_g3 = pow( ( lerpResult191_g3 * _Glossiness ) , _RoughnessSmoothnessCorrection );
			#else
				float staticSwitch189_g3 = ( 1.0 - pow( ( staticSwitch207_g3 * _Glossiness ) , _RoughnessSmoothnessCorrection ) );
			#endif
			float3 newWorldNormal3_g4 = (WorldNormalVector( i , staticSwitch181_g3 ));
			float3 temp_output_6_0_g4 = ddx( newWorldNormal3_g4 );
			float dotResult7_g4 = dot( temp_output_6_0_g4 , temp_output_6_0_g4 );
			float3 temp_output_10_0_g4 = ddy( newWorldNormal3_g4 );
			float dotResult12_g4 = dot( temp_output_10_0_g4 , temp_output_10_0_g4 );
			#ifdef _GeometricSpecularAA
				float staticSwitch187_g3 = ( 1.0 - pow( saturate( max( dotResult7_g4 , dotResult12_g4 ) ) , 0.333 ) );
			#else
				float staticSwitch187_g3 = 1.0;
			#endif
			o.Smoothness = min( staticSwitch189_g3 , staticSwitch187_g3 );
			float2 uv_MetallicGlossMap205_g3 = i.uv_texcoord;
			#ifdef _PACKEDMASK_ON
				float staticSwitch204_g3 = tex2D( _MetallicGlossMap, uv_MetallicGlossMap205_g3 ).g;
			#else
				float staticSwitch204_g3 = tex2D( _OcclusionMap, staticSwitch127_g3 ).r;
			#endif
			o.Occlusion = ( staticSwitch204_g3 * _OcclusionStrength );
			o.Alpha = temp_output_8_0_g3.a;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			sampler3D _DitherMaskLOD;
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
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
0;1191;2276;889;1468.208;109.2362;1;True;True
Node;AmplifyShaderEditor.FunctionNode;23;-512,-128;Inherit;False;EsnyaPBR;0;;3;d7448cd6078718a4b92322da44cf5771;2,179,0,175,1;1;180;FLOAT2;0,0;False;11;FLOAT3;0;FLOAT3;34;FLOAT3;42;FLOAT;30;FLOAT;17;FLOAT;44;FLOAT3;89;FLOAT3;96;FLOAT;84;FLOAT;14;FLOAT3;115
Node;AmplifyShaderEditor.IntNode;24;-666.7084,306.2638;Inherit;False;Property;_CullMode;CullMode;38;0;Fetch;False;1;Shader Options;0;1;CullMode;True;0;False;2;0;False;0;1;INT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-89,-125;Float;False;True;-1;2;EsnyaFactory.EsnyaPBRGUI;0;0;Standard;Esnya PBR/Transparent;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;True;True;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;24;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;0;23;0
WireConnection;0;1;23;34
WireConnection;0;2;23;42
WireConnection;0;3;23;30
WireConnection;0;4;23;17
WireConnection;0;5;23;44
WireConnection;0;9;23;14
WireConnection;0;11;23;115
ASEEND*/
//CHKSM=C7E53C0171A8A56EE14294A5922BC6A6EFBC5A29