// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EsnyaShaders/ProcedualSeaSky"
{
	Properties
	{
		_SunSize("Sun Size", Range( 0 , 1)) = 0.04
		_SunSizeConvergence("Sun Size Convergence", Range( 0 , 10)) = 5
		_AtmosphereThickness("Atmosphere Thickness", Range( 0 , 5)) = 1
		_AtmosphereAttenuationBias("Atmosphere Attenuation Bias", Float) = 0
		[Gamma]_AtmosphereAttenuation("Atmosphere Attenuation", Float) = 0
		_SkyTint("Sky Tint", Color) = (0.5,0.5,0.5,1)
		[KeywordEnum(None,Simple,HighQuarity)] _SunDisk("Sun", Float) = 2
		_Exposure("Exposure", Range( 0 , 8)) = 1.3
		[Toggle(_FAKESEA_ON)] _FakeSea("Fake Sea", Float) = 1
		_Color2("Deep Color", Color) = (0.05098039,0.2196078,0.3764706,1)
		_WaveStrength("Wave Strength", Float) = 1
		[Gamma]_WaveDistanceAttenuation("Wave Distance Attenuation", Range( 0 , 1)) = 0.5
		[Header(Wave1)]_Wave1Direction("Wave 1 Direction", Vector) = (0.2,0.5,0,0)
		_Wave1Speed("Wave 1 Speed", Float) = 4.5
		_Wave1Scale("Wave 1 Scale", Float) = 0.03
		_Wave1Strength("Wave 1 Strength", Float) = 3.2
		_Wave1Curve("Wave 1 Curve", Float) = 1.5
		_Wave2Curve("Wave 2 Curve", Float) = 1.5
		[Header(Wave2)]_Wave2Direction("Wave 2 Direction", Vector) = (-0.2,0.05,0,0)
		_Wave2Speed("Wave 2 Speed", Float) = 0.8
		_Wave2Scale("Wave 2 Scale", Float) = 0.3
		_Wave2Strength("Wave 2 Strength", Float) = 0.5
		[Header(Fresnel)][Space]_FresnelBias("Fresnel Bias", Float) = 0
		_FresnelScale("Fresnel Scale", Float) = 1
		_FresnelPower("Fresnel Power", Float) = 5
		[Header(Tweaks)][Space]_WaterSurfaceProjectionScale("Water Surface Projection Scale", Float) = 0.01
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Background"  "Queue" = "Background+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "DisableBatching" = "True" "IsEmissive" = "true"  "PreviewType"="Skybox" }
		Cull Off
		ZWrite Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma shader_feature _FAKESEA_ON
		#pragma multi_compile _SUNDISK_NONE _SUNDISK_SIMPLE _SUNDISK_HIGHQUARITY
		#pragma surface surf Unlit keepalpha noshadow noinstancing noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float3 worldPos;
			INTERNAL_DATA
		};

		uniform float _Exposure;
		uniform float4 _SkyTint;
		uniform float _AtmosphereThickness;
		uniform float _AtmosphereAttenuation;
		uniform float _AtmosphereAttenuationBias;
		uniform float _SunSizeConvergence;
		uniform float _SunSize;
		uniform float4 _Color2;
		uniform float _WaterSurfaceProjectionScale;
		uniform float2 _Wave1Direction;
		uniform float _Wave1Speed;
		uniform float _Wave1Scale;
		uniform float _Wave1Strength;
		uniform float _Wave1Curve;
		uniform float2 _Wave2Direction;
		uniform float _Wave2Speed;
		uniform float _Wave2Scale;
		uniform float _Wave2Strength;
		uniform float _Wave2Curve;
		uniform float _WaveStrength;
		uniform float _WaveDistanceAttenuation;
		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;


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


		float3 PerturbNormal61_g250( float3 surf_pos, float3 surf_norm, float height, float scale )
		{
			// "Bump Mapping Unparametrized Surfaces on the GPU" by Morten S. Mikkelsen
			float3 vSigmaS = ddx( surf_pos );
			float3 vSigmaT = ddy( surf_pos );
			float3 vN = surf_norm;
			float3 vR1 = cross( vSigmaT , vN );
			float3 vR2 = cross( vN , vSigmaS );
			float fDet = dot( vSigmaS , vR1 );
			float dBs = ddx( height );
			float dBt = ddy( height );
			float3 vSurfGrad = scale * 0.05 * sign( fDet ) * ( dBs * vR1 + dBt * vR2 );
			return normalize ( abs( fDet ) * vN - vSurfGrad );
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float temp_output_37_0_g284 = ( 1.025 - 1.0 );
			float temp_output_45_0_g284 = ( ( 1.0 / temp_output_37_0_g284 ) / 0.25 );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir92_g284 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz;
			float3 normalizeResult94_g284 = normalize( objToWorldDir92_g284 );
			float lerpResult301_g284 = lerp( 1.0 , -1.0 , step( normalizeResult94_g284.y , 0.0 ));
			float3 appendResult89_g284 = (float3(0.0 , ( 0.0001 + 1.0 ) , 0.0));
			float dotResult116_g284 = dot( ( normalizeResult94_g284 * lerpResult301_g284 ) , appendResult89_g284 );
			float temp_output_9_0_g293 = ( 1.0 - ( dotResult116_g284 / ( 1.0 + 0.0001 ) ) );
			float temp_output_123_0_g284 = ( ( sqrt( ( ( 1.025 * 1.025 ) + ( ( 1.0 * ( normalizeResult94_g284 * lerpResult301_g284 ).y * ( normalizeResult94_g284 * lerpResult301_g284 ).y ) - 1.0 ) ) ) - ( 1.0 * ( normalizeResult94_g284 * lerpResult301_g284 ).y ) ) / 2.0 );
			float3 temp_output_127_0_g284 = ( ( normalizeResult94_g284 * lerpResult301_g284 ) * temp_output_123_0_g284 );
			float3 temp_output_2_0_g286 = ( appendResult89_g284 + ( temp_output_127_0_g284 * float3( 0.5,0.5,0.5 ) ) );
			float temp_output_1_0_g286 = length( temp_output_2_0_g286 );
			float temp_output_8_0_g286 = exp( ( 0.0 * ( 1.0 - temp_output_1_0_g286 ) ) );
			float dotResult11_g286 = dot( _WorldSpaceLightPos0.xyz , temp_output_2_0_g286 );
			float temp_output_9_0_g288 = ( 1.0 - ( dotResult11_g286 / temp_output_1_0_g286 ) );
			float dotResult15_g286 = dot( ( normalizeResult94_g284 * lerpResult301_g284 ) , temp_output_2_0_g286 );
			float temp_output_9_0_g287 = ( 1.0 - ( dotResult15_g286 / temp_output_1_0_g286 ) );
			float clampResult27_g286 = clamp( ( ( exp( ( -1.0 * temp_output_45_0_g284 * 0.0001 ) ) * ( 0.25 * exp( ( -0.00287 + ( temp_output_9_0_g293 * ( 0.0459 + ( temp_output_9_0_g293 * ( 3.83 + ( temp_output_9_0_g293 * ( -6.8 + ( temp_output_9_0_g293 * 5.25 ) ) ) ) ) ) ) ) ) ) ) + ( temp_output_8_0_g286 * ( ( 0.25 * exp( ( -0.00287 + ( temp_output_9_0_g288 * ( 0.0459 + ( temp_output_9_0_g288 * ( 3.83 + ( temp_output_9_0_g288 * ( -6.8 + ( temp_output_9_0_g288 * 5.25 ) ) ) ) ) ) ) ) ) ) - ( 0.25 * exp( ( -0.00287 + ( temp_output_9_0_g287 * ( 0.0459 + ( temp_output_9_0_g287 * ( 3.83 + ( temp_output_9_0_g287 * ( -6.8 + ( temp_output_9_0_g287 * 5.25 ) ) ) ) ) ) ) ) ) ) ) ) ) , 0.0 , 50.0 );
			float3 temp_output_69_0_g284 = (_SkyTint).rgb;
			float3 lerpResult72_g284 = lerp( ( float3(0.65,0.57,0.475) - float3(0.15,0.15,0.15) ) , ( float3(0.65,0.57,0.475) + float3(0.15,0.15,0.15) ) , ( 1.0 - temp_output_69_0_g284 ));
			float3 temp_output_81_0_g284 = ( float3( 1,1,1 ) / pow( lerpResult72_g284 , 4.0 ) );
			float lerpResult20_g284 = lerp( 0.0 , 0.0025 , pow( ( _AtmosphereThickness / ( max( ( _AtmosphereAttenuation * ( (mul( unity_CameraToWorld, float4(0,0,0,1) )).y + _AtmosphereAttenuationBias ) ) , 0.0 ) + 1.0 ) ) , 2.5 ));
			float3 temp_output_2_0_g290 = ( temp_output_2_0_g286 + temp_output_127_0_g284 );
			float temp_output_1_0_g290 = length( temp_output_2_0_g290 );
			float temp_output_8_0_g290 = exp( ( temp_output_45_0_g284 * ( 1.0 - temp_output_1_0_g290 ) ) );
			float dotResult11_g290 = dot( _WorldSpaceLightPos0.xyz , temp_output_2_0_g290 );
			float temp_output_9_0_g292 = ( 1.0 - ( dotResult11_g290 / temp_output_1_0_g290 ) );
			float dotResult15_g290 = dot( ( normalizeResult94_g284 * lerpResult301_g284 ) , temp_output_2_0_g290 );
			float temp_output_9_0_g291 = ( 1.0 - ( dotResult15_g290 / temp_output_1_0_g290 ) );
			float clampResult27_g290 = clamp( ( ( exp( ( -1.0 * temp_output_45_0_g284 * 0.0001 ) ) * ( 0.25 * exp( ( -0.00287 + ( temp_output_9_0_g293 * ( 0.0459 + ( temp_output_9_0_g293 * ( 3.83 + ( temp_output_9_0_g293 * ( -6.8 + ( temp_output_9_0_g293 * 5.25 ) ) ) ) ) ) ) ) ) ) ) + ( temp_output_8_0_g290 * ( ( 0.25 * exp( ( -0.00287 + ( temp_output_9_0_g292 * ( 0.0459 + ( temp_output_9_0_g292 * ( 3.83 + ( temp_output_9_0_g292 * ( -6.8 + ( temp_output_9_0_g292 * 5.25 ) ) ) ) ) ) ) ) ) ) - ( 0.25 * exp( ( -0.00287 + ( temp_output_9_0_g291 * ( 0.0459 + ( temp_output_9_0_g291 * ( 3.83 + ( temp_output_9_0_g291 * ( -6.8 + ( temp_output_9_0_g291 * 5.25 ) ) ) ) ) ) ) ) ) ) ) ) ) , 0.0 , 50.0 );
			float3 temp_output_281_0_g284 = ( ( float3( 0,0,0 ) + ( exp( ( -1.0 * clampResult27_g286 * ( ( temp_output_81_0_g284 * ( ( lerpResult20_g284 * 4.0 ) * UNITY_PI ) ) + ( ( 0.001 * 4.0 ) * UNITY_PI ) ) ) ) * temp_output_8_0_g286 * ( temp_output_123_0_g284 * ( 1.0 / temp_output_37_0_g284 ) ) ) ) + ( exp( ( -1.0 * clampResult27_g290 * ( ( temp_output_81_0_g284 * ( ( lerpResult20_g284 * 4.0 ) * UNITY_PI ) ) + ( ( 0.001 * 4.0 ) * UNITY_PI ) ) ) ) * temp_output_8_0_g290 * ( temp_output_123_0_g284 * ( 1.0 / temp_output_37_0_g284 ) ) ) );
			float3 temp_output_142_0_g284 = ( temp_output_281_0_g284 * ( temp_output_81_0_g284 * ( 20.0 * lerpResult20_g284 ) ) );
			float dotResult7_g289 = dot( _WorldSpaceLightPos0.xyz , ( normalizeResult94_g284 * lerpResult301_g284 ) );
			float3 normalizeResult193_g284 = normalize( ( ( normalizeResult94_g284 * lerpResult301_g284 ) * -1.0 ) );
			float3 lerpResult198_g284 = lerp( ( _Exposure * ( temp_output_142_0_g284 * ( 0.75 + ( 0.75 * ( dotResult7_g289 * dotResult7_g289 ) ) ) ) ) , float3( 0,0,0 ) , saturate( ( normalizeResult193_g284.y / 0.02 ) ));
			float3 temp_output_143_0_g284 = ( temp_output_281_0_g284 * ( 0.001 * 20.0 ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float clampResult174_g284 = clamp( ase_lightColor.a , 0.25 , 1.0 );
			#if defined(_SUNDISK_NONE)
				float3 staticSwitch172_g284 = float3( 0,0,0 );
			#elif defined(_SUNDISK_SIMPLE)
				float3 staticSwitch172_g284 = ( ( 27.0 * saturate( ( temp_output_143_0_g284 * ( 400.0 * 20.0 ) ) ) * ase_lightColor.rgb ) / clampResult174_g284 );
			#elif defined(_SUNDISK_HIGHQUARITY)
				float3 staticSwitch172_g284 = ( ( 15.0 * saturate( temp_output_143_0_g284 ) * ase_lightColor.rgb ) / clampResult174_g284 );
			#else
				float3 staticSwitch172_g284 = ( ( 15.0 * saturate( temp_output_143_0_g284 ) * ase_lightColor.rgb ) / clampResult174_g284 );
			#endif
			float3 temp_output_14_0_g294 = _WorldSpaceLightPos0.xyz;
			float3 temp_output_224_0_g284 = ( normalizeResult94_g284 * 1.0 );
			float3 temp_output_15_0_g294 = temp_output_224_0_g284;
			float dotResult19_g294 = dot( temp_output_14_0_g294 , temp_output_15_0_g294 );
			float temp_output_13_0_g294 = pow( saturate( dotResult19_g294 ) , _SunSizeConvergence );
			float temp_output_21_0_g294 = _SunSize;
			float temp_output_21_0_g285 = _SunSize;
			float3 temp_output_14_0_g285 = _WorldSpaceLightPos0.xyz;
			float3 temp_output_15_0_g285 = temp_output_224_0_g284;
			float smoothstepResult10_g285 = smoothstep( temp_output_21_0_g285 , length( ( temp_output_14_0_g285 - temp_output_15_0_g285 ) ) , 0.0);
			#if defined(_SUNDISK_NONE)
				float staticSwitch222_g284 = 0.0;
			#elif defined(_SUNDISK_SIMPLE)
				float staticSwitch222_g284 = ( smoothstepResult10_g285 * smoothstepResult10_g285 );
			#elif defined(_SUNDISK_HIGHQUARITY)
				float staticSwitch222_g284 = ( ( 1.5 * ( ( 1.0 - 0.9801 ) / ( 2.0 + 0.9801 ) ) * ( 1.0 + ( temp_output_13_0_g294 * temp_output_13_0_g294 ) ) ) / max( pow( ( ( 1.0 + 0.9801 ) - ( 2.0 * -0.99 * ( temp_output_13_0_g294 * -1.0 ) ) ) , ( pow( temp_output_21_0_g294 , 0.65 ) * 10.0 ) ) , 0.0001 ) );
			#else
				float staticSwitch222_g284 = ( ( 1.5 * ( ( 1.0 - 0.9801 ) / ( 2.0 + 0.9801 ) ) * ( 1.0 + ( temp_output_13_0_g294 * temp_output_13_0_g294 ) ) ) / max( pow( ( ( 1.0 + 0.9801 ) - ( 2.0 * -0.99 * ( temp_output_13_0_g294 * -1.0 ) ) ) , ( pow( temp_output_21_0_g294 , 0.65 ) * 10.0 ) ) , 0.0001 ) );
			#endif
			float3 temp_output_204_0_g284 = ( lerpResult198_g284 + ( staticSwitch172_g284 * staticSwitch222_g284 ) );
			#if defined(_SUNDISK_NONE)
				float3 staticSwitch202_g284 = lerpResult198_g284;
			#elif defined(_SUNDISK_SIMPLE)
				float3 staticSwitch202_g284 = temp_output_204_0_g284;
			#elif defined(_SUNDISK_HIGHQUARITY)
				float3 staticSwitch202_g284 = temp_output_204_0_g284;
			#else
				float3 staticSwitch202_g284 = temp_output_204_0_g284;
			#endif
			float3 temp_output_122_226 = staticSwitch202_g284;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 temp_output_50_0_g250 = ( ( ( ase_worldViewDir * ( _WorldSpaceCameraPos.y / ase_worldViewDir.y ) ) - ( _WorldSpaceCameraPos * float3( 1,0,1 ) ) ) * _WaterSurfaceProjectionScale );
			float3 surf_pos61_g250 = temp_output_50_0_g250;
			float3 _Vector1 = float3(0,1,0);
			float3 temp_output_53_0_g250 = _Vector1;
			float3 surf_norm61_g250 = temp_output_53_0_g250;
			float3 break52_g250 = temp_output_50_0_g250;
			float2 appendResult14_g250 = (float2(break52_g250.x , break52_g250.z));
			float simplePerlin2D21_g250 = snoise( ( appendResult14_g250 + ( _Wave1Direction * _Wave1Speed * _Time.y ) )*_Wave1Scale );
			simplePerlin2D21_g250 = simplePerlin2D21_g250*0.5 + 0.5;
			float simplePerlin2D20_g250 = snoise( ( appendResult14_g250 + ( _Wave2Direction * _Wave2Speed * _Time.y ) )*_Wave2Scale );
			simplePerlin2D20_g250 = simplePerlin2D20_g250*0.5 + 0.5;
			float temp_output_41_0_g250 = ( pow( ( simplePerlin2D21_g250 * _Wave1Strength ) , _Wave1Curve ) + pow( ( simplePerlin2D20_g250 * _Wave2Strength ) , _Wave2Curve ) );
			float height61_g250 = temp_output_41_0_g250;
			float dotResult15_g250 = dot( temp_output_53_0_g250 , ase_worldViewDir );
			float temp_output_42_0_g250 = ( _WaveStrength * saturate( ( abs( dotResult15_g250 ) / _WaveDistanceAttenuation ) ) );
			float scale61_g250 = temp_output_42_0_g250;
			float3 localPerturbNormal61_g250 = PerturbNormal61_g250( surf_pos61_g250 , surf_norm61_g250 , height61_g250 , scale61_g250 );
			float3 temp_output_101_56 = localPerturbNormal61_g250;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult71 = dot( temp_output_101_56 , ase_worldlightDir );
			float fresnelNdotV95 = dot( _Vector1, ase_worldViewDir );
			float fresnelNode95 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV95, _FresnelPower ) );
			float dotResult116 = dot( temp_output_101_56 , ase_worldViewDir );
			float3 lerpResult60 = lerp( ( (_Color2).rgb * dotResult71 * temp_output_122_226 * ( 1.0 + fresnelNode95 ) ) , temp_output_122_226 , saturate( ( ( normalizeResult94_g284.y / 0.02 ) + saturate( ( 1.0 - dotResult116 ) ) ) ));
			#ifdef _FAKESEA_ON
				float3 staticSwitch120 = lerpResult60;
			#else
				float3 staticSwitch120 = temp_output_122_226;
			#endif
			o.Emission = staticSwitch120;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18910
0;770;1750;1310;397.5997;-761.1334;1;True;True
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;62;-1440,608;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;61;-1440,464;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;66;-1088,640;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-896,608;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-896,448;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;85;-704,448;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-1536,768;Inherit;False;Property;_WaterSurfaceProjectionScale;Water Surface Projection Scale;30;1;[Header];Create;True;1;Tweaks;0;0;False;1;Space;False;0.01;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;65;-1152,816;Inherit;False;Constant;_Vector1;Vector 1;3;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-577.9688,716.2696;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;115;0,896;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;101;-512,448;Inherit;True;Procedual Water;11;;250;00be91958253a3048bc5d9152655524e;1,54,0;3;50;FLOAT3;0,0,0;False;53;FLOAT3;0,0,0;False;55;FLOAT3;0,0,0;False;6;FLOAT;58;FLOAT3;0;FLOAT3;47;FLOAT3;56;FLOAT;48;FLOAT;49
Node;AmplifyShaderEditor.DotProductOpNode;116;256,768;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-749.7612,1095.498;Inherit;False;Property;_FresnelScale;Fresnel Scale;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;118;569.0313,793.2696;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-896,1024;Inherit;False;Property;_FresnelBias;Fresnel Bias;27;1;[Header];Create;True;1;Fresnel;0;0;False;1;Space;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-839.7612,1189.498;Inherit;False;Property;_FresnelPower;Fresnel Power;29;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;72;-416,704;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FresnelNode;95;-512,864;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;119;811.0313,817.2696;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;122;-634,66.5;Inherit;True;Procedual Sky;0;;284;63a55d02f8c6d5240aba01baae35afb3;0;0;4;FLOAT;282;FLOAT3;226;FLOAT3;276;FLOAT;236
Node;AmplifyShaderEditor.DotProductOpNode;71;0,512;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;0,672;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-100.9688,368.2696;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;105;128,256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;401.0645,454.2795;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;60;624,249;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;120;779.5313,135.7696;Inherit;False;Property;_FakeSea;Fake Sea;10;0;Create;True;0;0;0;False;0;False;0;1;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-450.5951,373.9434;Inherit;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1059,83;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;EsnyaShaders/ProcedualSeaSky;False;False;False;False;True;True;True;True;True;True;True;True;False;True;True;True;False;True;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Background;;Background;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;31;-1;-1;-1;1;PreviewType=Skybox;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;66;0;61;2
WireConnection;66;1;62;2
WireConnection;84;0;61;0
WireConnection;64;0;62;0
WireConnection;64;1;66;0
WireConnection;85;0;64;0
WireConnection;85;1;84;0
WireConnection;111;0;85;0
WireConnection;111;1;110;0
WireConnection;101;50;111;0
WireConnection;101;53;65;0
WireConnection;116;0;101;56
WireConnection;116;1;115;0
WireConnection;118;0;116;0
WireConnection;95;0;65;0
WireConnection;95;4;62;0
WireConnection;95;1;107;0
WireConnection;95;2;108;0
WireConnection;95;3;109;0
WireConnection;119;0;118;0
WireConnection;71;0;101;56
WireConnection;71;1;72;0
WireConnection;96;1;95;0
WireConnection;117;0;122;236
WireConnection;117;1;119;0
WireConnection;105;0;117;0
WireConnection;73;0;101;0
WireConnection;73;1;71;0
WireConnection;73;2;122;226
WireConnection;73;3;96;0
WireConnection;60;0;73;0
WireConnection;60;1;122;226
WireConnection;60;2;105;0
WireConnection;120;1;122;226
WireConnection;120;0;60;0
WireConnection;0;2;120;0
ASEEND*/
//CHKSM=0378D7C4C97698E0D47BC0747E050638B870E865