// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EsnyaPBR/EsnyaPBR Advanced"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Mode("Rendering Mode", Int) = 0
		[Toggle(_ALPHATEST_ON)] _AlphaTest("Alpha Test", Float) = 0
		[Toggle(_ALPHABLEND_ON)] _AlphaBlend("Alpha Blend", Float) = 0
		[NoScaleOffset][SingleLineTexture]_MetallicGlossMapS("Metallic Map", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		[SingleLineTexture]_MainTex("Albedo", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 1
		[NoScaleOffset][SingleLineTexture]_SpecGlossMap("Roughness Map", 2D) = "white" {}
		[Enum(Metallic Alpha,0,Albedo Alpha,1)]_SmoothnessTextureChannel("Smoothness Texture Channel", Float) = 0
		_Glossiness("Roughness / Smoothness", Range( 0 , 1)) = 1
		_RougnessCorrection("Rougness Correction", Float) = 0.45
		_SmoothnessCorrection("Smoothness Correction", Float) = 1
		[Toggle(_GeometricSpecularAA)] _GeometricSpecularAA("Geometric Specular AA", Float) = 0
		[Toggle(_NORMALMAP)] _NORMALMAP("Use Normal Map", Float) = 0
		[Toggle(_NORMALMAP_INVERT_Y)] _NORMALMAP_INVERT_Y("_NORMALMAP_INVERT_Y", Float) = 0
		[NoScaleOffset][Normal][SingleLineTexture]_BumpMap("Normal Map", 2D) = "bump" {}
		[VisibleIf(_NORMALMAP)]_BumpScale("Normal Scale", Float) = 1
		[Toggle(_EMISSION)] _EMISSION("Use Emission", Float) = 0
		[HDR][NoScaleOffset][SingleLineTexture]_EmissionMap("EmissionMap", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		[NoScaleOffset][SingleLineTexture]_OcclusionMap("Occlusion Map", 2D) = "white" {}
		_OcclusionStrength("Occlusion Strength", Float) = 1
		[NoScaleOffset][SingleLineTexture]_ParallaxMapS("Height Map", 2D) = "black" {}
		[NoScaleOffset][SingleLineTexture]_ParallaxMapS1("Height Map", 2D) = "black" {}
		[Toggle(_PARALLAXMAP)] _PARALLAXMAP("Use Height Map", Float) = 0
		_Parallax("Height Map Scale", Range( 0.005 , 0.08)) = 0.005
		[Header(Use Detail Map)][Toggle(_DETAIL_MULX2)] _DETAIL_MULX2("Use Detail Maps", Float) = 0
		[NoScaleOffset][SingleLineTexture]_DetailMask("Detail Mask", 2D) = "white" {}
		[SingleLineTexture]_DetailAlbedoMap("Detail Albedo", 2D) = "gray" {}
		[NoScaleOffset][Normal][SingleLineTexture]_DetailNormalMap("Detail Normal Map", 2D) = "bump" {}
		_DetailNormalMapScale("Detail Normal Map Scale", Float) = 1
		[Enum(UV1,0,UV2,1,UV3,2)]_UVSetforsecondarytextures("UV Set for secondary textures", Int) = 0
		[NoScaleOffset][SingleLineTexture]_TransmissionMap("Transmission Map", 2D) = "white" {}
		_TransmissionColor("Transmission Color", Color) = (0,0,0,0)
		[NoScaleOffset][SingleLineTexture]_TranslucencyMap("Translucency Map", 2D) = "white" {}
		_TranslucencyColor("Translucency Color", Color) = (0,0,0,0)
		[NoScaleOffset][SingleLineTexture]_RefractionMap("RefractionMap", 2D) = "white" {}
		_RefractionStrength("Refraction Strength", Float) = 1
		[Toggle(_PACKEDMASK_SPECGLOSSMAP)] _PACKEDMASK_SPECGLOSSMAP("_PACKEDMASK_SPECGLOSSMAP", Float) = 0
		[NoScaleOffset][SingleLineTexture]_ParallaxMap("Height Map", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]_MetallicGlossMap("Metallic Map", 2D) = "white" {}
		[Toggle(_METALLICGLOSSMAP)] _METALLICGLOSSMAP("_METALLICGLOSSMAP", Float) = 0
		[Toggle(_SPECGLOSSMAP)] _SPECGLOSSMAP("_SPECGLOSSMAP", Float) = 1
		[Toggle(_PACKEDMASK_METALLICGLOSSMAP)] _PACKEDMASK_METALLICGLOSSMAP("_PACKEDMASK_METALLICGLOSSMAP", Float) = 0
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		[Header(Refraction)]
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		[Enum(CullMode)]_CullMode("Cull Mode", Int) = 2
		[Toggle]_ZWrite("Z Write", Float) = 1
		[Enum(BlendMode)]__src("SrcBlend", Int) = 1
		[Enum(BlendMode)]__dst("DstBlend", Int) = 0
		[HideInInspector] _texcoord3( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull [_CullMode]
		ZWrite [_ZWrite]
		Blend [__src] [__dst]
		
		GrabPass{ }
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _EMISSION
		#pragma shader_feature _DETAIL_MULX2
		#pragma shader_feature _PARALLAXMAP
		#pragma shader_feature _GeometricSpecularAA
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON
		#pragma shader_feature _SPECGLOSSMAP _METALLICGLOSSMAP _PACKEDMASK_SPECGLOSSMAP _PACKEDMASK_METALLICGLOSSMAP
		#pragma shader_feature _ _NORMALMAP _NORMALMAP_INVERT_Y
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
			float2 uv_texcoord;
			float3 worldPos;
			float2 uv2_texcoord2;
			float2 uv3_texcoord3;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Transmission;
			half3 Translucency;
		};

		uniform int __src;
		uniform int __dst;
		uniform int _CullMode;
		uniform float _ZWrite;
		uniform float _Metallic;
		uniform float _SmoothnessTextureChannel;
		uniform float _DetailNormalMapScale;
		uniform sampler2D _BumpMap;
		uniform float _Parallax;
		uniform float4 _Color;
		uniform sampler2D _EmissionMap;
		uniform int _UVSetforsecondarytextures;
		uniform float _RougnessCorrection;
		uniform float _SmoothnessCorrection;
		uniform sampler2D _MainTex;
		uniform int _Mode;
		uniform sampler2D _ParallaxMapS;
		uniform float4 _EmissionColor;
		uniform sampler2D _ParallaxMapS1;
		uniform float _Glossiness;
		uniform sampler2D _MetallicGlossMapS;
		uniform sampler2D _OcclusionMap;
		uniform float _BumpScale;
		uniform sampler2D _SpecGlossMap;
		uniform float4 _MainTex_ST;
		uniform sampler2D _ParallaxMap;
		uniform sampler2D _MetallicGlossMap;
		uniform sampler2D _DetailNormalMap;
		uniform sampler2D _DetailAlbedoMap;
		uniform float4 _DetailAlbedoMap_ST;
		uniform sampler2D _DetailMask;
		uniform float _OcclusionStrength;
		uniform sampler2D _TransmissionMap;
		uniform float4 _TransmissionColor;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform sampler2D _TranslucencyMap;
		uniform float4 _TranslucencyColor;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;
		uniform sampler2D _RefractionMap;
		uniform float _RefractionStrength;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 _Vector2 = float3(0,0,0);
			v.vertex.xyz += _Vector2;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !defined(DIRECTIONAL)
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c + d;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		inline float4 Refraction( Input i, SurfaceOutputStandardCustom o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) );
			float2 cameraRefraction = float2( refractionOffset.x, refractionOffset.y );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutputStandardCustom o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode239_g5 = tex2D( _MetallicGlossMap, uv_MainTex );
			#ifdef _PACKEDMASK_SPECGLOSSMAP_ON
				float staticSwitch235_g5 = tex2DNode239_g5.g;
			#else
				float staticSwitch235_g5 = tex2D( _ParallaxMap, uv_MainTex ).r;
			#endif
			#ifdef _PACKEDMASK_SPECGLOSSMAP
				float staticSwitch236_g5 = tex2DNode239_g5.g;
			#else
				float staticSwitch236_g5 = staticSwitch235_g5;
			#endif
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 Offset118_g5 = ( ( staticSwitch236_g5 - 1 ) * ase_worldViewDir.xy * _Parallax ) + uv_MainTex;
			#ifdef _PARALLAXMAP
				float2 staticSwitch127_g5 = Offset118_g5;
			#else
				float2 staticSwitch127_g5 = uv_MainTex;
			#endif
			color.rgb = color.rgb + Refraction( i, o, ( tex2D( _RefractionMap, staticSwitch127_g5 ).r * _RefractionStrength ), _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode239_g5 = tex2D( _MetallicGlossMap, uv_MainTex );
			#ifdef _PACKEDMASK_SPECGLOSSMAP_ON
				float staticSwitch235_g5 = tex2DNode239_g5.g;
			#else
				float staticSwitch235_g5 = tex2D( _ParallaxMap, uv_MainTex ).r;
			#endif
			#ifdef _PACKEDMASK_SPECGLOSSMAP
				float staticSwitch236_g5 = tex2DNode239_g5.g;
			#else
				float staticSwitch236_g5 = staticSwitch235_g5;
			#endif
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 Offset118_g5 = ( ( staticSwitch236_g5 - 1 ) * ase_worldViewDir.xy * _Parallax ) + uv_MainTex;
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
			float2 uv_DetailAlbedoMap = i.uv_texcoord * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
			float2 uv2_DetailAlbedoMap = i.uv2_texcoord2 * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
			float2 uv3_DetailAlbedoMap = i.uv3_texcoord3 * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
			float2 lerpResult243_g5 = lerp( uv2_DetailAlbedoMap , uv3_DetailAlbedoMap , (float)saturate( ( _UVSetforsecondarytextures - 1 ) ));
			float2 lerpResult162_g5 = lerp( uv_DetailAlbedoMap , lerpResult243_g5 , (float)saturate( _UVSetforsecondarytextures ));
			float2 uv_DetailMask152_g5 = i.uv_texcoord;
			float3 lerpResult156_g5 = lerp( BlendNormals( UnpackScaleNormal( tex2D( _DetailNormalMap, lerpResult162_g5 ), _DetailNormalMapScale ) , staticSwitch143_g5 ) , staticSwitch143_g5 , tex2D( _DetailMask, uv_DetailMask152_g5 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch138_g5 = lerpResult156_g5;
			#else
				float3 staticSwitch138_g5 = staticSwitch143_g5;
			#endif
			#ifdef _NORMALMAP_INVERT_Y
				float3 staticSwitch224_g5 = ( staticSwitch138_g5 * float3(1,-1,1) );
			#else
				float3 staticSwitch224_g5 = staticSwitch138_g5;
			#endif
			o.Normal = staticSwitch224_g5;
			float4 tex2DNode5_g5 = tex2D( _MainTex, staticSwitch127_g5 );
			float4 temp_output_8_0_g5 = ( _Color * tex2DNode5_g5 );
			float3 temp_output_78_0_g5 = (temp_output_8_0_g5).rgb;
			float temp_output_9_0_g6 = tex2D( _DetailMask, uv_DetailMask152_g5 ).r;
			float temp_output_18_0_g6 = ( 1.0 - temp_output_9_0_g6 );
			float3 appendResult16_g6 = (float3(temp_output_18_0_g6 , temp_output_18_0_g6 , temp_output_18_0_g6));
			#ifdef _DETAIL_MULX2
				float3 staticSwitch131_g5 = ( temp_output_78_0_g5 * ( ( ( (tex2D( _DetailAlbedoMap, lerpResult162_g5 )).rgb * (unity_ColorSpaceDouble).rgb ) * temp_output_9_0_g6 ) + appendResult16_g6 ) );
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
			float4 tex2DNode28_g5 = tex2D( _MetallicGlossMap, staticSwitch127_g5 );
			o.Metallic = ( tex2DNode28_g5.r * _Metallic );
			#ifdef _SPECGLOSSMAP
				float staticSwitch225_g5 = ( 1.0 - pow( ( tex2D( _SpecGlossMap, staticSwitch127_g5 ).r * _Glossiness ) , _RougnessCorrection ) );
			#else
				float staticSwitch225_g5 = 0.0;
			#endif
			float lerpResult191_g5 = lerp( tex2DNode28_g5.a , tex2DNode5_g5.a , _SmoothnessTextureChannel);
			#ifdef _METALLICGLOSSMAP
				float staticSwitch226_g5 = pow( ( lerpResult191_g5 * _Glossiness ) , _RougnessCorrection );
			#else
				float staticSwitch226_g5 = staticSwitch225_g5;
			#endif
			#ifdef _PACKEDMASK_METALLICGLOSSMAP
				float staticSwitch227_g5 = pow( ( tex2DNode28_g5.a * _Glossiness ) , _SmoothnessCorrection );
			#else
				float staticSwitch227_g5 = staticSwitch226_g5;
			#endif
			#ifdef _PACKEDMASK_SPECGLOSSMAP
				float staticSwitch228_g5 = ( 1.0 - pow( ( tex2DNode28_g5.a * _Glossiness ) , _SmoothnessCorrection ) );
			#else
				float staticSwitch228_g5 = staticSwitch227_g5;
			#endif
			float3 newWorldNormal3_g7 = (WorldNormalVector( i , staticSwitch224_g5 ));
			float3 temp_output_6_0_g7 = ddx( newWorldNormal3_g7 );
			float dotResult7_g7 = dot( temp_output_6_0_g7 , temp_output_6_0_g7 );
			float3 temp_output_10_0_g7 = ddy( newWorldNormal3_g7 );
			float dotResult12_g7 = dot( temp_output_10_0_g7 , temp_output_10_0_g7 );
			#ifdef _GeometricSpecularAA
				float staticSwitch187_g5 = min( staticSwitch228_g5 , ( 1.0 - pow( saturate( max( dotResult7_g7 , dotResult12_g7 ) ) , 0.333 ) ) );
			#else
				float staticSwitch187_g5 = staticSwitch228_g5;
			#endif
			o.Smoothness = staticSwitch187_g5;
			#ifdef _PACKEDMASK_SPECGLOSSMAP_ON
				float staticSwitch241_g5 = tex2DNode28_g5.b;
			#else
				float staticSwitch241_g5 = tex2D( _OcclusionMap, staticSwitch127_g5 ).r;
			#endif
			#ifdef _PACKEDMASK_SPECGLOSSMAP
				float staticSwitch240_g5 = tex2DNode28_g5.b;
			#else
				float staticSwitch240_g5 = staticSwitch241_g5;
			#endif
			o.Occlusion = ( staticSwitch240_g5 * _OcclusionStrength );
			o.Transmission = ( (tex2D( _TransmissionMap, staticSwitch127_g5 )).rgb * (_TransmissionColor).rgb );
			o.Translucency = ( (tex2D( _TranslucencyMap, staticSwitch127_g5 )).rgb * (_TranslucencyColor).rgb );
			#ifdef _ALPHABLEND_ON
				float staticSwitch223_g5 = temp_output_8_0_g5.a;
			#else
				float staticSwitch223_g5 = 1.0;
			#endif
			o.Alpha = staticSwitch223_g5;
			#ifdef _ALPHATEST_ON
				float staticSwitch211_g5 = temp_output_8_0_g5.a;
			#else
				float staticSwitch211_g5 = 1.0;
			#endif
			clip( staticSwitch211_g5 - _Cutoff );
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustom keepalpha finalcolor:RefractionF fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

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
				float2 customPack2 : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float4 tSpace0 : TEXCOORD4;
				float4 tSpace1 : TEXCOORD5;
				float4 tSpace2 : TEXCOORD6;
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
				o.customPack2.xy = customInputData.uv3_texcoord3;
				o.customPack2.xy = v.texcoord2;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				surfIN.uv3_texcoord3 = IN.customPack2.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandardCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardCustom, o )
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
Version=18935
0;1097;1715;982;1847.599;541.4022;1;True;False
Node;AmplifyShaderEditor.IntNode;141;-1024,-127;Inherit;False;Property;__src;SrcBlend;60;1;[Enum];Create;False;0;0;1;BlendMode;True;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;143;-1024,-32;Inherit;False;Property;__dst;DstBlend;61;1;[Enum];Create;False;0;0;1;BlendMode;True;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;4;-1024,-384;Inherit;False;Property;_CullMode;Cull Mode;58;1;[Enum];Create;False;1;Shader Options;0;1;CullMode;True;0;False;2;0;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-1024,-256;Inherit;False;Property;_ZWrite;Z Write;59;1;[Toggle];Create;True;0;0;0;True;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;168;-640,-256;Inherit;False;EsnyaPBR;1;;5;d7448cd6078718a4b92322da44cf5771;2,179,0,175,1;1;180;FLOAT2;0,0;False;12;FLOAT3;0;FLOAT3;34;FLOAT3;42;FLOAT;30;FLOAT;17;FLOAT;44;FLOAT3;89;FLOAT3;96;FLOAT;84;FLOAT;14;FLOAT;212;FLOAT3;115
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-384,-256;Float;False;True;-1;2;EsnyaFactory.EsnyaPBRGUI;0;0;Standard;EsnyaPBR/EsnyaPBR Advanced;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;True;157;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Custom;;Geometry;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;1;5;True;141;10;True;143;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;49;56;-1;0;False;0;0;True;4;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;0;168;0
WireConnection;0;1;168;34
WireConnection;0;2;168;42
WireConnection;0;3;168;30
WireConnection;0;4;168;17
WireConnection;0;5;168;44
WireConnection;0;6;168;89
WireConnection;0;7;168;96
WireConnection;0;8;168;84
WireConnection;0;9;168;14
WireConnection;0;10;168;212
WireConnection;0;11;168;115
ASEEND*/
//CHKSM=0FC191026520FDCA3DAC7339833BCB3C82F02B51