// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EsnyaShaders/ProcedualWater"
{
	Properties
	{
		_Color("Surface Color", Color) = (0.282353,0.5294118,0.7058824,0.5019608)
		_Color2("Deep Color", Color) = (0.05098039,0.2196078,0.3764706,1)
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
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
		_ClippingFadeCurve("Clipping Fade Curve", Float) = 2
		_ClippingFadeEnd("Clipping Fade End", Range( 0 , 1)) = 1
		_ClippingFadeStart("Clipping Fade Start", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade keepalpha novertexlights nolightmap  nodirlightmap noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPosition34_g3;
			float eyeDepth;
		};

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
		uniform float4 _Color;
		uniform float4 _Color2;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Smoothness;
		uniform float _ClippingFadeEnd;
		uniform float _ClippingFadeStart;
		uniform float _ClippingFadeCurve;


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


		float3 PerturbNormal61_g3( float3 surf_pos, float3 surf_norm, float height, float scale )
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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 vertexPos34_g3 = ase_vertex3Pos;
			float4 ase_screenPos34_g3 = ComputeScreenPos( UnityObjectToClipPos( vertexPos34_g3 ) );
			o.screenPosition34_g3 = ase_screenPos34_g3;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 temp_output_50_0_g3 = ase_worldPos;
			float3 surf_pos61_g3 = temp_output_50_0_g3;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 objToWorldDir10_g3 = mul( unity_ObjectToWorld, float4( ase_vertexNormal, 0 ) ).xyz;
			float3 temp_output_53_0_g3 = objToWorldDir10_g3;
			float3 surf_norm61_g3 = temp_output_53_0_g3;
			float3 break52_g3 = temp_output_50_0_g3;
			float2 appendResult14_g3 = (float2(break52_g3.x , break52_g3.z));
			float simplePerlin2D21_g3 = snoise( ( appendResult14_g3 + ( _Wave1Direction * _Wave1Speed * _Time.y ) )*_Wave1Scale );
			simplePerlin2D21_g3 = simplePerlin2D21_g3*0.5 + 0.5;
			float simplePerlin2D20_g3 = snoise( ( appendResult14_g3 + ( _Wave2Direction * _Wave2Speed * _Time.y ) )*_Wave2Scale );
			simplePerlin2D20_g3 = simplePerlin2D20_g3*0.5 + 0.5;
			float temp_output_41_0_g3 = ( pow( ( simplePerlin2D21_g3 * _Wave1Strength ) , _Wave1Curve ) + pow( ( simplePerlin2D20_g3 * _Wave2Strength ) , _Wave2Curve ) );
			float height61_g3 = temp_output_41_0_g3;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult15_g3 = dot( temp_output_53_0_g3 , ase_worldViewDir );
			float temp_output_42_0_g3 = ( _WaveStrength * saturate( ( abs( dotResult15_g3 ) / _WaveDistanceAttenuation ) ) );
			float scale61_g3 = temp_output_42_0_g3;
			float3 localPerturbNormal61_g3 = PerturbNormal61_g3( surf_pos61_g3 , surf_norm61_g3 , height61_g3 , scale61_g3 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentDir60_g3 = mul( ase_worldToTangent, localPerturbNormal61_g3);
			o.Normal = worldToTangentDir60_g3;
			float4 ase_screenPos34_g3 = i.screenPosition34_g3;
			float4 ase_screenPosNorm34 = ase_screenPos34_g3 / ase_screenPos34_g3.w;
			ase_screenPosNorm34.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm34.z : ase_screenPosNorm34.z * 0.5 + 0.5;
			float screenDepth34_g3 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm34.xy ));
			float distanceDepth34_g3 = saturate( abs( ( screenDepth34_g3 - LinearEyeDepth( ase_screenPosNorm34.z ) ) / ( 10.0 ) ) );
			float4 lerpResult40_g3 = lerp( _Color , _Color2 , distanceDepth34_g3);
			float3 temp_output_109_0 = (lerpResult40_g3).rgb;
			o.Albedo = temp_output_109_0;
			float temp_output_109_48 = _Smoothness;
			o.Smoothness = temp_output_109_48;
			float cameraDepthFade110 = (( i.eyeDepth -_ProjectionParams.y - ( _ProjectionParams.z * _ClippingFadeStart ) ) / ( _ProjectionParams.z * _ClippingFadeEnd * ( 1.0 - _ClippingFadeStart ) ));
			float temp_output_125_0 = pow( saturate( cameraDepthFade110 ) , _ClippingFadeCurve );
			float lerpResult139 = lerp( lerpResult40_g3.a , 0.0 , temp_output_125_0);
			o.Alpha = lerpResult139;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18912
1004;897;1920;1006;-2520.961;-101.2745;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;118;3130,453;Inherit;False;Property;_ClippingFadeStart;Clipping Fade Start;18;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;123;3459,177;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ProjectionParams;119;3072,256;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;117;3200,0;Inherit;False;Property;_ClippingFadeEnd;Clipping Fade End;17;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;3704.768,130.7592;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;3681.768,254.7592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;110;3840,128;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;6000;False;1;FLOAT;3000;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;116;4091,296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;3974.768,513.7592;Inherit;False;Property;_ClippingFadeCurve;Clipping Fade Curve;16;0;Create;True;0;0;0;False;0;False;2;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;109;3761.651,-173.0129;Inherit;False;Procedual Water;0;;3;00be91958253a3048bc5d9152655524e;1,54,1;3;50;FLOAT3;0,0,0;False;53;FLOAT3;0,0,0;False;55;FLOAT3;0,0,0;False;6;FLOAT;58;FLOAT3;0;FLOAT3;47;FLOAT3;56;FLOAT;48;FLOAT;49
Node;AmplifyShaderEditor.PowerNode;125;4270.768,474.7592;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;135;3984.961,110.2745;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;127;4826.768,-142.2408;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;134;4325,146;Inherit;False;UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldReflection)@;4;Create;1;True;worldReflection;FLOAT3;0,0,0;In;;Inherit;False;SpecCube0;True;False;0;;False;1;0;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;137;4511.961,-109.7255;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;138;4827.961,-257.7255;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;139;4878.961,144.2745;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;136;4234.961,213.2745;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;140;4880.961,-41.72552;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;5110.806,-149.1395;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;EsnyaShaders/ProcedualWater;False;False;False;False;False;True;True;False;True;False;False;True;False;False;True;True;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;123;0;118;0
WireConnection;120;0;119;3
WireConnection;120;1;117;0
WireConnection;120;2;123;0
WireConnection;121;0;119;3
WireConnection;121;1;118;0
WireConnection;110;0;120;0
WireConnection;110;1;121;0
WireConnection;116;0;110;0
WireConnection;125;0;116;0
WireConnection;125;1;126;0
WireConnection;127;1;137;0
WireConnection;127;2;125;0
WireConnection;134;0;136;0
WireConnection;137;0;134;0
WireConnection;138;0;109;0
WireConnection;138;2;125;0
WireConnection;139;0;109;49
WireConnection;139;2;125;0
WireConnection;136;0;135;0
WireConnection;140;0;109;48
WireConnection;140;2;125;0
WireConnection;0;0;109;0
WireConnection;0;1;109;47
WireConnection;0;4;109;48
WireConnection;0;9;139;0
ASEEND*/
//CHKSM=B4D59ECDAF7CCD30DA866D12D67A22D5A16ABD32