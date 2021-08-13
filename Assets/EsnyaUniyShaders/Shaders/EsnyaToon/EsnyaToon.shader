// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EsnyaToon/EsnyaToon"
{
	Properties
	{
		[Header(Main Textures)][SingleLineTexture]_MainTex("Main Tex", 2D) = "white" {}
		[NoScaleOffset][Normal][SingleLineTexture]_BumpMap("Normal", 2D) = "bump" {}
		[HDR][NoScaleOffset][SingleLineTexture]_EmissionMap("Emission Map", 2D) = "black" {}
		[Toggle(_NORMALMAP)] _NORMALMAP("Normal Map", Float) = 0
		[Header(Shadow 1)][NoScaleOffset][SingleLineTexture]_Shadow1("Shadow 1", 2D) = "white" {}
		_Shadow1Color("Shadow 1 Color", Color) = (0.8,0.8,0.8,1)
		_Shadow1Position("Shadow 1 Position", Range( -1 , 1)) = 0.5
		[Gamma]_Shadow1Smooth("Shadow 1 Smooth", Range( 0 , 1)) = 0
		[Header(Shadow 2)][NoScaleOffset][SingleLineTexture]_Shadow2("Shadow 2", 2D) = "white" {}
		_Shadow2Color("Shadow 2 Color", Color) = (0.6,0.6,0.6,1)
		_Shadow2Position("Shadow 2 Position", Range( 0 , 2)) = 0.1
		[Gamma]_Shadow2Smooth("Shadow 2 Smooth", Range( 0 , 1)) = 0
		[Header(Outline)]_OutlineWidth("Outline Width", Float) = 0.001
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		[NoScaleOffset][SingleLineTexture]_OutlineMask("Outline Mask", 2D) = "white" {}
		[Header(Misc)]_UnlitFactor("Unlit Factor", Range( 0 , 1)) = 0.01
		[Enum(CullMode)]_CullMode("Cull Mode", Int) = 0
		[Toggle]_ZWrite("Z Write", Float) = 1
		[Enum(BlendMode)]__dst("Dst Blend", Int) = 0
		[Enum(BlendMode)]__src("Src Blend", Int) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		UsePass "EsnyaToon/Internal/Outline/Unlit"
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull [_CullMode]
		ZWrite [_ZWrite]
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _NORMALMAP
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
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _OutlineColor;
		uniform int __dst;
		uniform int __src;
		uniform sampler2D _OutlineMask;
		uniform float _ZWrite;
		uniform int _CullMode;
		uniform float _OutlineWidth;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Shadow1Color;
		uniform sampler2D _Shadow1;
		uniform float4 _Shadow2Color;
		uniform sampler2D _Shadow2;
		uniform float _Shadow2Position;
		uniform float _Shadow2Smooth;
		uniform sampler2D _BumpMap;
		uniform float _Shadow1Position;
		uniform float _Shadow1Smooth;
		uniform float _UnlitFactor;
		uniform sampler2D _EmissionMap;


		inline float3 ShadeSH958( float4 In0 )
		{
			return ShadeSH9(In0);
		}


		inline float3 ShadeSH960( float4 In0 )
		{
			return ShadeSH9(In0);
		}


		inline float3 ShadeSH966( float4 In0 )
		{
			return ShadeSH9(In0);
		}


		inline float3 ShadeSH965( float4 In0 )
		{
			return ShadeSH9(In0);
		}


		inline float3 ShadeSH970( float4 In0 )
		{
			return ShadeSH9(In0);
		}


		inline float3 ShadeSH969( float4 In0 )
		{
			return ShadeSH9(In0);
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			#ifdef _NORMALMAP
				float3 staticSwitch123 = UnpackNormal( tex2D( _BumpMap, uv_MainTex ) );
			#else
				float3 staticSwitch123 = float3(0,0,1);
			#endif
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult19 = dot( (WorldNormalVector( i , staticSwitch123 )) , ase_worldlightDir );
			float temp_output_122_0 = ( 1.0 - ( dotResult19 * ase_lightAtten ) );
			float smoothstepResult118 = smoothstep( ( _Shadow2Position - _Shadow2Smooth ) , _Shadow2Position , temp_output_122_0);
			float3 lerpResult31 = lerp( ( (_Shadow1Color).rgb * (tex2D( _Shadow1, uv_MainTex )).rgb ) , ( (_Shadow2Color).rgb * (tex2D( _Shadow2, uv_MainTex )).rgb ) , smoothstepResult118);
			float smoothstepResult112 = smoothstep( ( _Shadow1Position - _Shadow1Smooth ) , _Shadow1Position , temp_output_122_0);
			float3 lerpResult29 = lerp( float3(1,1,1) , lerpResult31 , smoothstepResult112);
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 In058 = float4( float3(0,0,1) , 0.0 );
			float3 localShadeSH958 = ShadeSH958( In058 );
			float4 In060 = float4( float3(0,0,-1) , 0.0 );
			float3 localShadeSH960 = ShadeSH960( In060 );
			float4 In066 = float4( float3(0,1,0) , 0.0 );
			float3 localShadeSH966 = ShadeSH966( In066 );
			float4 In065 = float4( float3(0,-1,0) , 0.0 );
			float3 localShadeSH965 = ShadeSH965( In065 );
			float4 In070 = float4( float3(0,1,0) , 0.0 );
			float3 localShadeSH970 = ShadeSH970( In070 );
			float4 In069 = float4( float3(0,-1,0) , 0.0 );
			float3 localShadeSH969 = ShadeSH969( In069 );
			float3 lerpResult79 = lerp( saturate( ( ( ase_lightColor.rgb * ase_lightColor.a ) + max( max( max( localShadeSH958 , localShadeSH960 ) , max( localShadeSH966 , localShadeSH965 ) ) , max( localShadeSH970 , localShadeSH969 ) ) ) ) , float3(1,1,1) , _UnlitFactor);
			c.rgb = ( ( (tex2D( _MainTex, uv_MainTex )).rgb * lerpResult29 * lerpResult79 ) + (tex2D( _EmissionMap, uv_MainTex )).rgb );
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows nodirlightmap nofog noforwardadd 

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
				float2 customPack1 : TEXCOORD1;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18912
0;923;1772;1157;3141.402;823.5852;6.577304;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;1568,1936;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;2;992,1568;Inherit;True;Property;_BumpMap;Normal;2;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;False;0;False;None;4b66a7f4b8c91d2449bcefecd62ec76f;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;4;1312,1568;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;126;1312,1408;Inherit;False;Constant;_Vector8;Vector 8;24;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;61;2288,2432;Inherit;False;Constant;_Vector1;Vector 1;13;0;Create;True;0;0;0;False;0;False;0,0,-1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;63;2288,2592;Inherit;False;Constant;_Vector2;Vector 2;13;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;123;1632,1408;Inherit;False;Property;_NORMALMAP;Normal Map;5;0;Create;False;0;0;0;False;0;False;0;0;1;True;_NORMALMAP;Toggle;2;Key0;Key1;Create;False;False;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;64;2288,2752;Inherit;False;Constant;_Vector3;Vector 3;13;0;Create;True;0;0;0;False;0;False;0,-1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;59;2288,2272;Inherit;False;Constant;_Vector0;Vector 0;13;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CustomExpressionNode;66;2480,2592;Inherit;False;ShadeSH9(In0);3;Create;1;True;In0;FLOAT4;0,0,1,0;In;;Inherit;False;ShadeSH9;True;False;0;;False;1;0;FLOAT4;0,0,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;60;2480,2432;Inherit;False;ShadeSH9(In0);3;Create;1;True;In0;FLOAT4;0,0,1,0;In;;Inherit;False;ShadeSH9;True;False;0;;False;1;0;FLOAT4;0,0,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;58;2480,2272;Inherit;False;ShadeSH9(In0);3;Create;1;True;In0;FLOAT4;0,0,1,0;In;;Inherit;False;ShadeSH9;True;False;0;;False;1;0;FLOAT4;0,0,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;67;2288,2912;Inherit;False;Constant;_Vector4;Vector 4;13;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;18;1856,1568;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CustomExpressionNode;65;2480,2752;Inherit;False;ShadeSH9(In0);3;Create;1;True;In0;FLOAT4;0,0,1,0;In;;Inherit;False;ShadeSH9;True;False;0;;False;1;0;FLOAT4;0,0,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;68;2288,3072;Inherit;False;Constant;_Vector5;Vector 5;13;0;Create;True;0;0;0;False;0;False;0,-1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;13;1856,1408;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;98;2208,1184;Inherit;True;Property;_Shadow2;Shadow 2;10;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;True;1;Shadow 2;0;0;False;0;False;None;ed36902f8c6888f4593f4f6905abe1be;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.LightAttenuation;85;2144,1504;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;71;2656,2592;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;97;2208,800;Inherit;True;Property;_Shadow1;Shadow 1;6;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;True;1;Shadow 1;0;0;False;0;False;None;9e455ffeb39a8b448ab5cc6c75ddf537;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DotProductOpNode;19;2144,1408;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;70;2480,2912;Inherit;False;ShadeSH9(In0);3;Create;1;True;In0;FLOAT4;0,0,1,0;In;;Inherit;False;ShadeSH9;True;False;0;;False;1;0;FLOAT4;0,0,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;69;2480,3072;Inherit;False;ShadeSH9(In0);3;Create;1;True;In0;FLOAT4;0,0,1,0;In;;Inherit;False;ShadeSH9;True;False;0;;False;1;0;FLOAT4;0,0,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;62;2656,2272;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;99;2496,800;Inherit;True;Property;_TextureSample3;Texture Sample 3;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;23;2496,608;Inherit;False;Property;_Shadow1Color;Shadow 1 Color;7;0;Create;True;0;0;0;False;0;False;0.8,0.8,0.8,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;72;2656,2912;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;73;2784,2272;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;121;2400,1749.213;Inherit;False;Property;_Shadow2Smooth;Shadow 2 Smooth;13;1;[Gamma];Create;True;0;0;0;False;0;False;0;0.09999994;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;2368,1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;100;2496,1184;Inherit;True;Property;_TextureSample4;Texture Sample 4;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;2400,1845.213;Inherit;False;Property;_Shadow2Position;Shadow 2 Position;12;0;Create;True;0;0;0;False;0;False;0.1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;24;2496,992;Inherit;False;Property;_Shadow2Color;Shadow 2 Color;11;0;Create;True;0;0;0;False;0;False;0.6,0.6,0.6,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;75;2288,2144;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMaxOpNode;74;2912,2272;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;122;2512,1408;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;2912,2144;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;27;2592,2048;Inherit;False;Property;_Shadow1Position;Shadow 1 Position;8;0;Create;True;0;0;0;False;0;False;0.5;0.057;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;104;2816,608;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;103;2816,992;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;113;2592,1952;Inherit;False;Property;_Shadow1Smooth;Shadow 1 Smooth;9;1;[Gamma];Create;True;0;0;0;False;0;False;0;0.09999994;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;117;2688,1749.213;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;107;2816,800;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;108;2816,1184;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;3040,992;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;3040,608;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;3072,2144;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;1;3008,256;Inherit;True;Property;_MainTex;Main Tex;0;2;[Header];[SingleLineTexture];Create;True;1;Main Textures;0;0;False;0;False;None;3de958c2e191bb047a7b32fdace29a40;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SmoothstepOpNode;118;2816,1408;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.45;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;114;2880,1952;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;106;3264,448;Inherit;False;Constant;_Vector7;Vector 7;19;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;80;3264,2256;Inherit;False;Constant;_Vector6;Vector 6;13;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SmoothstepOpNode;112;3072,1952;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.45;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;78;3264,2144;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;31;3264,608;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;3;3264,256;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;6;3008,2528;Inherit;True;Property;_EmissionMap;Emission Map;3;3;[HDR];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;None;ee2702ff86e61c742a505b45d8b60cce;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;21;3264,2416;Inherit;False;Property;_UnlitFactor;Unlit Factor;17;1;[Header];Create;True;1;Misc;0;0;False;0;False;0.01;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;79;3584,2144;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;5;3280,2528;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;29;3584,448;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;101;3584,256;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;3808,256;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;102;3584,2528;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-542.3697,1793.916;Inherit;False;Property;_ZWrite;Z Write;19;1;[Toggle];Create;True;0;0;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;3968,256;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;124;3512.271,930.4033;Inherit;False;Property;_ToggleSwitch0;Toggle Switch0;22;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;83;-544,1696;Inherit;False;Property;_CullMode;Cull Mode;18;1;[Enum];Create;True;0;0;1;CullMode;True;0;False;0;2;False;0;1;INT;0
Node;AmplifyShaderEditor.TexturePropertyNode;55;-107.4794,1584.923;Inherit;True;Property;_OutlineMask;Outline Mask;16;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;True;0;False;None;c3fabe94c6e8f484998cbf86cca1e628;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;53;160,1760;Inherit;False;Property;_OutlineWidth;Outline Width;14;1;[Header];Create;True;1;Outline;0;0;True;0;False;0.001;0.0004;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-32,464;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;82;-528,1600;Inherit;False;Property;__dst;Dst Blend;20;1;[Enum];Create;False;0;0;1;BlendMode;True;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-23.12423,366.0679;Inherit;False;Property;_Metallic;Metallic;1;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;52;160,1552;Inherit;False;Property;_OutlineColor;Outline Color;15;0;Create;True;0;0;0;True;0;False;0,0,0,1;0.1886791,0.09522944,0.09522944,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;81;-696.374,1605.682;Inherit;False;Property;__src;Src Blend;21;1;[Enum];Create;False;0;0;1;BlendMode;True;0;False;0;1;False;0;1;INT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;93;4224,256;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;EsnyaToon/EsnyaToon;False;False;False;False;False;False;False;False;True;True;False;True;False;False;False;False;False;False;False;False;False;Back;1;True;96;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;True;81;10;True;82;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;83;-1;0;False;-1;0;0;1;Above;EsnyaToon/Internal/Outline/Unlit;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;2;0
WireConnection;4;1;17;0
WireConnection;4;7;2;1
WireConnection;123;1;126;0
WireConnection;123;0;4;0
WireConnection;66;0;63;0
WireConnection;60;0;61;0
WireConnection;58;0;59;0
WireConnection;65;0;64;0
WireConnection;13;0;123;0
WireConnection;71;0;66;0
WireConnection;71;1;65;0
WireConnection;19;0;13;0
WireConnection;19;1;18;0
WireConnection;70;0;67;0
WireConnection;69;0;68;0
WireConnection;62;0;58;0
WireConnection;62;1;60;0
WireConnection;99;0;97;0
WireConnection;99;1;17;0
WireConnection;99;7;97;1
WireConnection;72;0;70;0
WireConnection;72;1;69;0
WireConnection;73;0;62;0
WireConnection;73;1;71;0
WireConnection;94;0;19;0
WireConnection;94;1;85;0
WireConnection;100;0;98;0
WireConnection;100;1;17;0
WireConnection;100;7;98;1
WireConnection;74;0;73;0
WireConnection;74;1;72;0
WireConnection;122;0;94;0
WireConnection;76;0;75;1
WireConnection;76;1;75;2
WireConnection;104;0;23;0
WireConnection;103;0;24;0
WireConnection;117;0;33;0
WireConnection;117;1;121;0
WireConnection;107;0;99;0
WireConnection;108;0;100;0
WireConnection;110;0;103;0
WireConnection;110;1;108;0
WireConnection;109;0;104;0
WireConnection;109;1;107;0
WireConnection;77;0;76;0
WireConnection;77;1;74;0
WireConnection;118;0;122;0
WireConnection;118;1;117;0
WireConnection;118;2;33;0
WireConnection;114;0;27;0
WireConnection;114;1;113;0
WireConnection;112;0;122;0
WireConnection;112;1;114;0
WireConnection;112;2;27;0
WireConnection;78;0;77;0
WireConnection;31;0;109;0
WireConnection;31;1;110;0
WireConnection;31;2;118;0
WireConnection;3;0;1;0
WireConnection;3;1;17;0
WireConnection;3;7;1;1
WireConnection;79;0;78;0
WireConnection;79;1;80;0
WireConnection;79;2;21;0
WireConnection;5;0;6;0
WireConnection;5;1;17;0
WireConnection;5;7;6;1
WireConnection;29;0;106;0
WireConnection;29;1;31;0
WireConnection;29;2;112;0
WireConnection;101;0;3;0
WireConnection;22;0;101;0
WireConnection;22;1;29;0
WireConnection;22;2;79;0
WireConnection;102;0;5;0
WireConnection;16;0;22;0
WireConnection;16;1;102;0
WireConnection;93;13;16;0
ASEEND*/
//CHKSM=F621CB77035C491886AB2D35716871C61D7A4F10