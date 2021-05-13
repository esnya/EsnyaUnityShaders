// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Esnya PBR/Advanced/Transparent"
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
		[Header(Transmission)][NoScaleOffset]_TransmissionMap("Transmission Map", 2D) = "white" {}
		_TransmissionColor("Transmission Color", Color) = (0,0,0,0)
		[Header(Translucency)][NoScaleOffset]_TranslucencyMap("Translucency Map", 2D) = "white" {}
		_TranslucencyColor("Translucency Color", Color) = (0,0,0,0)
		[Header(Refraction)][NoScaleOffset]_RefractionMap("RefractionMap", 2D) = "white" {}
		_RefractionStrength("Refraction Strength", Float) = 1
		[Header(Z Shift)][Toggle(_ZSHIFT_ON)] _ZShift("Z Shift", Float) = 0
		[VisibleIf(_ZSHIFT_ON)]_ZShiftScale("Z Shift Scale", Float) = 0.005
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		[Header(Refraction)]
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		[Header(Shader Options)][Enum(CullMode)]_CullMode("Cull Mode", Int) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		GrabPass{ }
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
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float2 uv2_texcoord2;
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
			float3 worldToObjDir105_g13 = mul( unity_WorldToObject, float4( ase_worldViewDir, 0 ) ).xyz;
			float3 objToWorld110_g13 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult109_g13 = (float2(( objToWorld110_g13.x + objToWorld110_g13.y ) , ( objToWorld110_g13.y + objToWorld110_g13.z )));
			float simpleNoise106_g13 = SimpleNoise( appendResult109_g13*1000.0 );
			simpleNoise106_g13 = simpleNoise106_g13*2 - 1;
			#ifdef _ZSHIFT_ON
				float3 staticSwitch112_g13 = ( worldToObjDir105_g13 * simpleNoise106_g13 * _ZShiftScale );
			#else
				float3 staticSwitch112_g13 = float3(0,0,0);
			#endif
			v.vertex.xyz += staticSwitch112_g13;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !DIRECTIONAL
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
			float2 uv_ParallaxMap119_g13 = i.uv_texcoord;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 Offset118_g13 = ( ( tex2D( _ParallaxMap, uv_ParallaxMap119_g13 ).r - 1 ) * ase_worldViewDir.xy * _Parallax ) + uv_MainTex;
			#ifdef _PARALLAXMAP
				float2 staticSwitch127_g13 = Offset118_g13;
			#else
				float2 staticSwitch127_g13 = uv_MainTex;
			#endif
			color.rgb = color.rgb + Refraction( i, o, ( tex2D( _RefractionMap, staticSwitch127_g13 ).r * _RefractionStrength ), _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 uv_ParallaxMap119_g13 = i.uv_texcoord;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 Offset118_g13 = ( ( tex2D( _ParallaxMap, uv_ParallaxMap119_g13 ).r - 1 ) * ase_worldViewDir.xy * _Parallax ) + uv_MainTex;
			#ifdef _PARALLAXMAP
				float2 staticSwitch127_g13 = Offset118_g13;
			#else
				float2 staticSwitch127_g13 = uv_MainTex;
			#endif
			#ifdef _NORMALMAP
				float3 staticSwitch143_g13 = UnpackScaleNormal( tex2D( _BumpMap, staticSwitch127_g13 ), _BumpScale );
			#else
				float3 staticSwitch143_g13 = float3(0,0,1);
			#endif
			float2 uv2_MainTex = i.uv2_texcoord2 * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 lerpResult162_g13 = lerp( uv_MainTex , uv2_MainTex , (float)_UVSetforsecondarytextures);
			float2 uv_DetailMask152_g13 = i.uv_texcoord;
			float3 lerpResult156_g13 = lerp( BlendNormals( UnpackScaleNormal( tex2D( _DetailNormalMap, lerpResult162_g13 ), _DetailNormalMapScale ) , staticSwitch143_g13 ) , staticSwitch143_g13 , tex2D( _DetailMask, uv_DetailMask152_g13 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch138_g13 = lerpResult156_g13;
			#else
				float3 staticSwitch138_g13 = staticSwitch143_g13;
			#endif
			#ifdef _NEAGTENORMALG_ON
				float3 staticSwitch181_g13 = ( staticSwitch138_g13 * float3(1,-1,1) );
			#else
				float3 staticSwitch181_g13 = staticSwitch138_g13;
			#endif
			o.Normal = staticSwitch181_g13;
			float4 temp_output_8_0_g13 = ( _Color * tex2D( _MainTex, staticSwitch127_g13 ) );
			float3 temp_output_78_0_g13 = (temp_output_8_0_g13).rgb;
			float2 uv_DetailAlbedoMap = i.uv_texcoord * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
			float3 lerpResult157_g13 = lerp( (tex2D( _DetailAlbedoMap, uv_DetailAlbedoMap )).rgb , temp_output_78_0_g13 , tex2D( _DetailMask, uv_DetailMask152_g13 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch131_g13 = lerpResult157_g13;
			#else
				float3 staticSwitch131_g13 = temp_output_78_0_g13;
			#endif
			o.Albedo = staticSwitch131_g13;
			#ifdef _EMISSION
				float3 staticSwitch129_g13 = ( (tex2D( _EmissionMap, staticSwitch127_g13 )).rgb * (_EmissionColor).rgb );
			#else
				float3 staticSwitch129_g13 = float3( 0,0,0 );
			#endif
			o.Emission = staticSwitch129_g13;
			o.Metallic = ( tex2D( _MetallicGlossMap, staticSwitch127_g13 ).r * _Metallic );
			o.Smoothness = ( 1.0 - pow( ( tex2D( _SpecGlossMap, staticSwitch127_g13 ).r * _Glossiness ) , _RoughnessCorrection ) );
			o.Occlusion = ( tex2D( _OcclusionMap, staticSwitch127_g13 ).r * _OcclusionStrength );
			o.Transmission = ( (tex2D( _TransmissionMap, staticSwitch127_g13 )).rgb * (_TransmissionColor).rgb );
			o.Translucency = ( (tex2D( _TranslucencyMap, staticSwitch127_g13 )).rgb * (_TranslucencyColor).rgb );
			o.Alpha = temp_output_8_0_g13.a;
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustom alpha:fade keepalpha finalcolor:RefractionF fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

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
				float3 worldPos : TEXCOORD2;
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
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
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
Version=18900
0;1191;2599;889;1569.95;346.3253;1;True;True
Node;AmplifyShaderEditor.FunctionNode;14;-642.9976,-130.1833;Inherit;False;EsnyaPBR;0;;13;da1a8a67aa976ee4a9419c7e6f582eff;2,179,0,175,1;1;180;FLOAT2;0,0;False;11;FLOAT3;0;FLOAT3;34;FLOAT3;42;FLOAT;30;FLOAT;17;FLOAT;44;FLOAT3;89;FLOAT3;96;FLOAT;84;FLOAT;14;FLOAT3;115
Node;AmplifyShaderEditor.IntNode;4;-608,192;Inherit;False;Property;_CullMode;Cull Mode;43;2;[Header];[Enum];Create;False;1;Shader Options;0;1;CullMode;True;0;False;2;2;False;0;1;INT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-89,-125;Float;False;True;-1;2;EsnyaFactory.EsnyaPBRGUI;0;0;Standard;Esnya PBR/Advanced/Transparent;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;34;41;-1;0;False;0;0;True;4;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;0;14;0
WireConnection;0;1;14;34
WireConnection;0;2;14;42
WireConnection;0;3;14;30
WireConnection;0;4;14;17
WireConnection;0;5;14;44
WireConnection;0;6;14;89
WireConnection;0;7;14;96
WireConnection;0;8;14;84
WireConnection;0;9;14;14
WireConnection;0;11;14;115
ASEEND*/
//CHKSM=6E34A77EA8D19C51ACCF5483AAADE05C9FF381FB