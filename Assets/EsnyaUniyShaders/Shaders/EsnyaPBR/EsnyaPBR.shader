// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EsnyaPBR/Standard"
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
		[Toggle(_PARALLAXMAP)] _PARALLAXMAP("Use Height Map", Float) = 0
		[NoScaleOffset][SingleLineTexture]_ParallaxMapS1("Height Map", 2D) = "black" {}
		[NoScaleOffset][SingleLineTexture]_ParallaxMapS("Height Map", 2D) = "black" {}
		_Parallax("Height Map Scale", Range( 0.005 , 0.08)) = 0.005
		[Header(Use Detail Map)][Toggle(_DETAIL_MULX2)] _DETAIL_MULX2("Use Detail Maps", Float) = 0
		[NoScaleOffset][SingleLineTexture]_DetailMask("Detail Mask", 2D) = "white" {}
		[SingleLineTexture]_DetailAlbedoMap("Detail Albedo", 2D) = "white" {}
		[NoScaleOffset][Normal][SingleLineTexture]_DetailNormalMap("Detail Normal Map", 2D) = "bump" {}
		_DetailNormalMapScale("Detail Normal Map Scale", Float) = 1
		[Enum(UV1,0,UV2,1)]_UVSetforsecondarytextures("UV Set for secondary textures", Int) = 0
		[Toggle(_PACKEDMASK_SPECGLOSSMAP)] _PACKEDMASK_SPECGLOSSMAP("_PACKEDMASK_SPECGLOSSMAP", Float) = 0
		[NoScaleOffset][SingleLineTexture]_ParallaxMap("Height Map", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]_MetallicGlossMap("Metallic Map", 2D) = "white" {}
		[Toggle(_METALLICGLOSSMAP)] _METALLICGLOSSMAP("_METALLICGLOSSMAP", Float) = 0
		[Toggle(_SPECGLOSSMAP)] _SPECGLOSSMAP("_SPECGLOSSMAP", Float) = 1
		[Toggle(_PACKEDMASK_METALLICGLOSSMAP)] _PACKEDMASK_METALLICGLOSSMAP("_PACKEDMASK_METALLICGLOSSMAP", Float) = 0
		[Enum(CullMode)]_CullMode("Cull Mode", Int) = 2
		[Toggle]_ZWrite("Z Write", Float) = 1
		[Enum(BlendMode)]__src("SrcBlend", Int) = 1
		[Enum(BlendMode)]__dst("DstBlend", Int) = 0
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
		
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _EMISSION
		#pragma shader_feature _DETAIL_MULX2
		#pragma shader_feature _PARALLAXMAP
		#pragma shader_feature _GeometricSpecularAA
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
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform int __dst;
		uniform int __src;
		uniform int _CullMode;
		uniform float _ZWrite;
		uniform float4 _EmissionColor;
		uniform float _Glossiness;
		uniform int _Mode;
		uniform float _Metallic;
		uniform float _SmoothnessCorrection;
		uniform sampler2D _SpecGlossMap;
		uniform float _BumpScale;
		uniform sampler2D _ParallaxMapS;
		uniform sampler2D _ParallaxMapS1;
		uniform float _RougnessCorrection;
		uniform sampler2D _OcclusionMap;
		uniform sampler2D _MetallicGlossMapS;
		uniform float _SmoothnessTextureChannel;
		uniform sampler2D _BumpMap;
		uniform int _UVSetforsecondarytextures;
		uniform float _DetailNormalMapScale;
		uniform sampler2D _MainTex;
		uniform float _Parallax;
		uniform float4 _Color;
		uniform sampler2D _EmissionMap;
		uniform float4 _MainTex_ST;
		uniform sampler2D _ParallaxMap;
		uniform sampler2D _MetallicGlossMap;
		uniform sampler2D _DetailNormalMap;
		uniform sampler2D _DetailMask;
		uniform sampler2D _DetailAlbedoMap;
		uniform float4 _DetailAlbedoMap_ST;
		uniform float _OcclusionStrength;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 _Vector2 = float3(0,0,0);
			v.vertex.xyz += _Vector2;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode239_g21 = tex2D( _MetallicGlossMap, uv_MainTex );
			#ifdef _PACKEDMASK_SPECGLOSSMAP_ON
				float staticSwitch235_g21 = tex2DNode239_g21.g;
			#else
				float staticSwitch235_g21 = tex2D( _ParallaxMap, uv_MainTex ).r;
			#endif
			#ifdef _PACKEDMASK_SPECGLOSSMAP
				float staticSwitch236_g21 = tex2DNode239_g21.g;
			#else
				float staticSwitch236_g21 = staticSwitch235_g21;
			#endif
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 Offset118_g21 = ( ( staticSwitch236_g21 - 1 ) * ase_worldViewDir.xy * _Parallax ) + uv_MainTex;
			#ifdef _PARALLAXMAP
				float2 staticSwitch127_g21 = Offset118_g21;
			#else
				float2 staticSwitch127_g21 = uv_MainTex;
			#endif
			#ifdef _NORMALMAP
				float3 staticSwitch143_g21 = UnpackScaleNormal( tex2D( _BumpMap, staticSwitch127_g21 ), _BumpScale );
			#else
				float3 staticSwitch143_g21 = float3(0,0,1);
			#endif
			float2 uv2_MainTex = i.uv2_texcoord2 * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 lerpResult162_g21 = lerp( uv_MainTex , uv2_MainTex , (float)_UVSetforsecondarytextures);
			float2 uv_DetailMask152_g21 = i.uv_texcoord;
			float3 lerpResult156_g21 = lerp( BlendNormals( UnpackScaleNormal( tex2D( _DetailNormalMap, lerpResult162_g21 ), _DetailNormalMapScale ) , staticSwitch143_g21 ) , staticSwitch143_g21 , tex2D( _DetailMask, uv_DetailMask152_g21 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch138_g21 = lerpResult156_g21;
			#else
				float3 staticSwitch138_g21 = staticSwitch143_g21;
			#endif
			#ifdef _NORMALMAP_INVERT_Y
				float3 staticSwitch224_g21 = ( staticSwitch138_g21 * float3(1,-1,1) );
			#else
				float3 staticSwitch224_g21 = staticSwitch138_g21;
			#endif
			o.Normal = staticSwitch224_g21;
			float4 tex2DNode5_g21 = tex2D( _MainTex, staticSwitch127_g21 );
			float4 temp_output_8_0_g21 = ( _Color * tex2DNode5_g21 );
			float3 temp_output_78_0_g21 = (temp_output_8_0_g21).rgb;
			float2 uv_DetailAlbedoMap = i.uv_texcoord * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
			float temp_output_9_0_g23 = tex2D( _DetailMask, uv_DetailMask152_g21 ).r;
			float temp_output_18_0_g23 = ( 1.0 - temp_output_9_0_g23 );
			float3 appendResult16_g23 = (float3(temp_output_18_0_g23 , temp_output_18_0_g23 , temp_output_18_0_g23));
			#ifdef _DETAIL_MULX2
				float3 staticSwitch131_g21 = ( temp_output_78_0_g21 * ( ( ( (tex2D( _DetailAlbedoMap, uv_DetailAlbedoMap )).rgb * (unity_ColorSpaceDouble).rgb ) * temp_output_9_0_g23 ) + appendResult16_g23 ) );
			#else
				float3 staticSwitch131_g21 = temp_output_78_0_g21;
			#endif
			o.Albedo = staticSwitch131_g21;
			#ifdef _EMISSION
				float3 staticSwitch129_g21 = ( (tex2D( _EmissionMap, staticSwitch127_g21 )).rgb * (_EmissionColor).rgb );
			#else
				float3 staticSwitch129_g21 = float3( 0,0,0 );
			#endif
			o.Emission = staticSwitch129_g21;
			float4 tex2DNode28_g21 = tex2D( _MetallicGlossMap, staticSwitch127_g21 );
			o.Metallic = ( tex2DNode28_g21.r * _Metallic );
			#ifdef _SPECGLOSSMAP
				float staticSwitch225_g21 = ( 1.0 - pow( ( tex2D( _SpecGlossMap, staticSwitch127_g21 ).r * _Glossiness ) , _RougnessCorrection ) );
			#else
				float staticSwitch225_g21 = 0.0;
			#endif
			float lerpResult191_g21 = lerp( tex2DNode28_g21.a , tex2DNode5_g21.a , _SmoothnessTextureChannel);
			#ifdef _METALLICGLOSSMAP
				float staticSwitch226_g21 = pow( ( lerpResult191_g21 * _Glossiness ) , _RougnessCorrection );
			#else
				float staticSwitch226_g21 = staticSwitch225_g21;
			#endif
			#ifdef _PACKEDMASK_METALLICGLOSSMAP
				float staticSwitch227_g21 = pow( ( tex2DNode28_g21.a * _Glossiness ) , _SmoothnessCorrection );
			#else
				float staticSwitch227_g21 = staticSwitch226_g21;
			#endif
			#ifdef _PACKEDMASK_SPECGLOSSMAP
				float staticSwitch228_g21 = ( 1.0 - pow( ( tex2DNode28_g21.a * _Glossiness ) , _SmoothnessCorrection ) );
			#else
				float staticSwitch228_g21 = staticSwitch227_g21;
			#endif
			float3 newWorldNormal3_g22 = (WorldNormalVector( i , staticSwitch224_g21 ));
			float3 temp_output_6_0_g22 = ddx( newWorldNormal3_g22 );
			float dotResult7_g22 = dot( temp_output_6_0_g22 , temp_output_6_0_g22 );
			float3 temp_output_10_0_g22 = ddy( newWorldNormal3_g22 );
			float dotResult12_g22 = dot( temp_output_10_0_g22 , temp_output_10_0_g22 );
			#ifdef _GeometricSpecularAA
				float staticSwitch187_g21 = min( staticSwitch228_g21 , ( 1.0 - pow( saturate( max( dotResult7_g22 , dotResult12_g22 ) ) , 0.333 ) ) );
			#else
				float staticSwitch187_g21 = staticSwitch228_g21;
			#endif
			o.Smoothness = staticSwitch187_g21;
			#ifdef _PACKEDMASK_SPECGLOSSMAP_ON
				float staticSwitch241_g21 = tex2DNode28_g21.b;
			#else
				float staticSwitch241_g21 = tex2D( _OcclusionMap, staticSwitch127_g21 ).r;
			#endif
			#ifdef _PACKEDMASK_SPECGLOSSMAP
				float staticSwitch240_g21 = tex2DNode28_g21.b;
			#else
				float staticSwitch240_g21 = staticSwitch241_g21;
			#endif
			o.Occlusion = ( staticSwitch240_g21 * _OcclusionStrength );
			#ifdef _ALPHABLEND_ON
				float staticSwitch223_g21 = temp_output_8_0_g21.a;
			#else
				float staticSwitch223_g21 = 1.0;
			#endif
			o.Alpha = staticSwitch223_g21;
			#ifdef _ALPHATEST_ON
				float staticSwitch211_g21 = temp_output_8_0_g21.a;
			#else
				float staticSwitch211_g21 = 1.0;
			#endif
			clip( staticSwitch211_g21 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

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
Version=18912
0;1248;2353;832;1873.664;537.8958;1;True;True
Node;AmplifyShaderEditor.IntNode;141;-1024,-127;Inherit;False;Property;__src;SrcBlend;51;1;[Enum];Create;False;0;0;1;BlendMode;True;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;143;-1024,-32;Inherit;False;Property;__dst;DstBlend;52;1;[Enum];Create;False;0;0;1;BlendMode;True;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-1024,-256;Inherit;False;Property;_ZWrite;Z Write;50;1;[Toggle];Create;True;0;0;0;True;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;4;-1024,-384;Inherit;False;Property;_CullMode;Cull Mode;49;1;[Enum];Create;False;1;Shader Options;0;1;CullMode;True;0;False;2;0;False;0;1;INT;0
Node;AmplifyShaderEditor.FunctionNode;183;-640,-256;Inherit;False;EsnyaPBR;1;;21;d7448cd6078718a4b92322da44cf5771;2,179,0,175,1;1;180;FLOAT2;0,0;False;12;FLOAT3;0;FLOAT3;34;FLOAT3;42;FLOAT;30;FLOAT;17;FLOAT;44;FLOAT3;89;FLOAT3;96;FLOAT;84;FLOAT;14;FLOAT;212;FLOAT3;115
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-253,-246;Float;False;True;-1;2;EsnyaFactory.EsnyaPBRGUI;0;0;Standard;EsnyaPBR/Standard;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;True;157;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Custom;;Geometry;ForwardOnly;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;1;5;True;141;10;True;143;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;True;4;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;0;183;0
WireConnection;0;1;183;34
WireConnection;0;2;183;42
WireConnection;0;3;183;30
WireConnection;0;4;183;17
WireConnection;0;5;183;44
WireConnection;0;9;183;14
WireConnection;0;10;183;212
WireConnection;0;11;183;115
ASEEND*/
//CHKSM=46B9AA01DE3865C706035EDE300D102D476D5009