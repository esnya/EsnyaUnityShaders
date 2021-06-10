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
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade keepalpha nolightmap  nodirlightmap nometa noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPosition34_g3;
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


		float3 PerturbNormal107_g4( float3 surf_pos, float3 surf_norm, float height, float scale )
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
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 surf_pos107_g4 = ase_worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 surf_norm107_g4 = ase_worldNormal;
			float2 appendResult14_g3 = (float2(ase_worldPos.x , ase_worldPos.z));
			float simplePerlin2D21_g3 = snoise( ( appendResult14_g3 + ( _Wave1Direction * _Wave1Speed * _Time.y ) )*_Wave1Scale );
			simplePerlin2D21_g3 = simplePerlin2D21_g3*0.5 + 0.5;
			float simplePerlin2D20_g3 = snoise( ( appendResult14_g3 + ( _Wave2Direction * _Wave2Speed * _Time.y ) )*_Wave2Scale );
			simplePerlin2D20_g3 = simplePerlin2D20_g3*0.5 + 0.5;
			float height107_g4 = ( pow( ( simplePerlin2D21_g3 * _Wave1Strength ) , _Wave1Curve ) + pow( ( simplePerlin2D20_g3 * _Wave2Strength ) , _Wave2Curve ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 objToWorldDir10_g3 = mul( unity_ObjectToWorld, float4( ase_vertexNormal, 0 ) ).xyz;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult15_g3 = dot( objToWorldDir10_g3 , ase_worldViewDir );
			float scale107_g4 = ( _WaveStrength * saturate( ( abs( dotResult15_g3 ) / _WaveDistanceAttenuation ) ) );
			float3 localPerturbNormal107_g4 = PerturbNormal107_g4( surf_pos107_g4 , surf_norm107_g4 , height107_g4 , scale107_g4 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentDir42_g4 = mul( ase_worldToTangent, localPerturbNormal107_g4);
			o.Normal = worldToTangentDir42_g4;
			float4 ase_screenPos34_g3 = i.screenPosition34_g3;
			float4 ase_screenPosNorm34 = ase_screenPos34_g3 / ase_screenPos34_g3.w;
			ase_screenPosNorm34.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm34.z : ase_screenPosNorm34.z * 0.5 + 0.5;
			float screenDepth34_g3 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm34.xy ));
			float distanceDepth34_g3 = saturate( abs( ( screenDepth34_g3 - LinearEyeDepth( ase_screenPosNorm34.z ) ) / ( 10.0 ) ) );
			float4 lerpResult40_g3 = lerp( _Color , _Color2 , distanceDepth34_g3);
			o.Albedo = (lerpResult40_g3).rgb;
			o.Smoothness = _Smoothness;
			o.Alpha = lerpResult40_g3.a;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18909
0;1192;1553;888;-3435.268;240.2408;1;True;True
Node;AmplifyShaderEditor.FunctionNode;109;3982.651,49.98707;Inherit;False;Procedual Water;0;;3;00be91958253a3048bc5d9152655524e;0;0;4;FLOAT3;47;FLOAT;48;FLOAT;49;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4595.806,-221.1395;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;EsnyaShaders/ProcedualWater;False;False;False;False;False;False;True;False;True;False;True;True;False;False;True;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;0;109;0
WireConnection;0;1;109;47
WireConnection;0;4;109;48
WireConnection;0;9;109;49
ASEEND*/
//CHKSM=C773948633C212A23E3E73CB2C0A699611E80521