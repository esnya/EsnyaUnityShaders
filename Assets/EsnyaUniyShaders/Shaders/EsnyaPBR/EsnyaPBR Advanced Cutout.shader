// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Esnya PBR/Advanced/Cutout"
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
		[Header(Z Shift)][Toggle(_ZSHIFT_ON)] _ZShift("Z Shift", Float) = 0
		[VisibleIf(_ZSHIFT_ON)]_ZShiftScale("Z Shift Scale", Float) = 0.005
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		[Header(Shader Options)][Enum(CullMode)]_CullMode("Cull Mode", Int) = 2
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull [_CullMode]
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#pragma shader_feature _ZSHIFT_ON
		#pragma shader_feature _NEAGTENORMALG_ON
		#pragma shader_feature _DETAIL_MULX2
		#pragma shader_feature _NORMALMAP
		#pragma shader_feature _PARALLAXMAP
		#pragma shader_feature _EMISSION
		#pragma surface surf StandardCustom keepalpha addshadow fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float2 uv2_texcoord2;
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
			float3 worldToObjDir105_g7 = mul( unity_WorldToObject, float4( ase_worldViewDir, 0 ) ).xyz;
			float3 objToWorld110_g7 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult109_g7 = (float2(( objToWorld110_g7.x + objToWorld110_g7.y ) , ( objToWorld110_g7.y + objToWorld110_g7.z )));
			float simpleNoise106_g7 = SimpleNoise( appendResult109_g7*1000.0 );
			simpleNoise106_g7 = simpleNoise106_g7*2 - 1;
			#ifdef _ZSHIFT_ON
				float3 staticSwitch112_g7 = ( worldToObjDir105_g7 * simpleNoise106_g7 * _ZShiftScale );
			#else
				float3 staticSwitch112_g7 = float3(0,0,0);
			#endif
			v.vertex.xyz += staticSwitch112_g7;
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

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 uv_ParallaxMap119_g7 = i.uv_texcoord;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 Offset118_g7 = ( ( tex2D( _ParallaxMap, uv_ParallaxMap119_g7 ).r - 1 ) * ase_worldViewDir.xy * _Parallax ) + uv_MainTex;
			#ifdef _PARALLAXMAP
				float2 staticSwitch127_g7 = Offset118_g7;
			#else
				float2 staticSwitch127_g7 = uv_MainTex;
			#endif
			#ifdef _NORMALMAP
				float3 staticSwitch143_g7 = UnpackScaleNormal( tex2D( _BumpMap, staticSwitch127_g7 ), _BumpScale );
			#else
				float3 staticSwitch143_g7 = float3(0,0,1);
			#endif
			float2 uv2_MainTex = i.uv2_texcoord2 * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 lerpResult162_g7 = lerp( uv_MainTex , uv2_MainTex , (float)_UVSetforsecondarytextures);
			float2 uv_DetailMask152_g7 = i.uv_texcoord;
			float3 lerpResult156_g7 = lerp( BlendNormals( UnpackScaleNormal( tex2D( _DetailNormalMap, lerpResult162_g7 ), _DetailNormalMapScale ) , staticSwitch143_g7 ) , staticSwitch143_g7 , tex2D( _DetailMask, uv_DetailMask152_g7 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch138_g7 = lerpResult156_g7;
			#else
				float3 staticSwitch138_g7 = staticSwitch143_g7;
			#endif
			#ifdef _NEAGTENORMALG_ON
				float3 staticSwitch181_g7 = ( staticSwitch138_g7 * float3(1,-1,1) );
			#else
				float3 staticSwitch181_g7 = staticSwitch138_g7;
			#endif
			o.Normal = staticSwitch181_g7;
			float4 temp_output_8_0_g7 = ( _Color * tex2D( _MainTex, staticSwitch127_g7 ) );
			float3 temp_output_78_0_g7 = (temp_output_8_0_g7).rgb;
			float2 uv_DetailAlbedoMap = i.uv_texcoord * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
			float3 lerpResult157_g7 = lerp( (tex2D( _DetailAlbedoMap, uv_DetailAlbedoMap )).rgb , temp_output_78_0_g7 , tex2D( _DetailMask, uv_DetailMask152_g7 ).r);
			#ifdef _DETAIL_MULX2
				float3 staticSwitch131_g7 = lerpResult157_g7;
			#else
				float3 staticSwitch131_g7 = temp_output_78_0_g7;
			#endif
			o.Albedo = staticSwitch131_g7;
			#ifdef _EMISSION
				float3 staticSwitch129_g7 = ( (tex2D( _EmissionMap, staticSwitch127_g7 )).rgb * (_EmissionColor).rgb );
			#else
				float3 staticSwitch129_g7 = float3( 0,0,0 );
			#endif
			o.Emission = staticSwitch129_g7;
			o.Metallic = ( tex2D( _MetallicGlossMap, staticSwitch127_g7 ).r * _Metallic );
			o.Smoothness = ( 1.0 - pow( ( tex2D( _SpecGlossMap, staticSwitch127_g7 ).r * _Glossiness ) , _RoughnessCorrection ) );
			o.Occlusion = ( tex2D( _OcclusionMap, staticSwitch127_g7 ).r * _OcclusionStrength );
			o.Transmission = ( (tex2D( _TransmissionMap, staticSwitch127_g7 )).rgb * (_TransmissionColor).rgb );
			o.Translucency = ( (tex2D( _TranslucencyMap, staticSwitch127_g7 )).rgb * (_TranslucencyColor).rgb );
			o.Alpha = 1;
			clip( temp_output_8_0_g7.a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "EsnyaFactory.EsnyaPBRGUI"
}
/*ASEBEGIN
Version=18900
0;1191;2599;889;1566.241;444.1084;1;True;True
Node;AmplifyShaderEditor.FunctionNode;9;-512,-128;Inherit;False;EsnyaPBR;0;;7;da1a8a67aa976ee4a9419c7e6f582eff;2,179,0,175,1;1;180;FLOAT2;0,0;False;11;FLOAT3;0;FLOAT3;34;FLOAT3;42;FLOAT;30;FLOAT;17;FLOAT;44;FLOAT3;89;FLOAT3;96;FLOAT;84;FLOAT;14;FLOAT3;115
Node;AmplifyShaderEditor.IntNode;4;-512,160;Inherit;False;Property;_CullMode;Cull Mode;41;2;[Header];[Enum];Create;False;1;Shader Options;0;1;CullMode;True;0;False;2;0;False;0;1;INT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,-128;Float;False;True;-1;2;EsnyaFactory.EsnyaPBRGUI;0;0;Standard;Esnya PBR/Advanced/Cutout;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;42;34;-1;-1;0;False;0;0;True;4;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;0;9;0
WireConnection;0;1;9;34
WireConnection;0;2;9;42
WireConnection;0;3;9;30
WireConnection;0;4;9;17
WireConnection;0;5;9;44
WireConnection;0;6;9;89
WireConnection;0;7;9;96
WireConnection;0;10;9;14
WireConnection;0;11;9;115
ASEEND*/
//CHKSM=BC1E67A00DFDB860522C652381308A494CEFFCDD