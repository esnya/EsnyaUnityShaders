// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ProcedualWater"
{
	Properties
	{
		_Color("Color", Color) = (0,0.4166667,1,0.5019608)
		_Color2("Color2", Color) = (0,0.4166667,1,0.5019608)
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_WaveStrength("Wave Strength", Float) = 1
		[Gamma]_WaveDistanceAttenuation("Wave Distance Attenuation", Range( 0 , 1)) = 0.1
		[Header(Wave1)]_Wave1Direction("Wave 1 Direction", Vector) = (0.1,0.2,0,0)
		_Wave1Speed("Wave 1 Speed", Float) = 1
		_Wave1Scale("Wave 1 Scale", Float) = 1
		_Wave1Strength("Wave 1 Strength", Float) = 1
		_Wave1Curve("Wave 1 Curve", Float) = 1
		_Wave2Curve("Wave 2 Curve", Float) = 1
		[Header(Wave2)]_Wave2Direction("Wave 2 Direction", Vector) = (-0.1,0.3,0,0)
		_Wave2Speed("Wave 2 Speed", Float) = 1
		_Wave2Scale("Wave 2 Scale", Float) = 1
		_Wave2Strength("Wave 2 Strength", Float) = 1
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
			float4 screenPosition100;
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


		float3 PerturbNormal107_g1( float3 surf_pos, float3 surf_norm, float height, float scale )
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
			float3 vertexPos100 = ase_vertex3Pos;
			float4 ase_screenPos100 = ComputeScreenPos( UnityObjectToClipPos( vertexPos100 ) );
			o.screenPosition100 = ase_screenPos100;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 surf_pos107_g1 = ase_worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 surf_norm107_g1 = ase_worldNormal;
			float2 appendResult15 = (float2(ase_worldPos.x , ase_worldPos.z));
			float simplePerlin2D12 = snoise( ( appendResult15 + ( _Wave1Direction * _Wave1Speed * _Time.y ) )*_Wave1Scale );
			simplePerlin2D12 = simplePerlin2D12*0.5 + 0.5;
			float simplePerlin2D35 = snoise( ( appendResult15 + ( _Wave2Direction * _Wave2Speed * _Time.y ) )*_Wave2Scale );
			simplePerlin2D35 = simplePerlin2D35*0.5 + 0.5;
			float height107_g1 = ( pow( ( simplePerlin2D12 * _Wave1Strength ) , _Wave1Curve ) + pow( ( simplePerlin2D35 * _Wave2Strength ) , _Wave2Curve ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 objToWorldDir73 = mul( unity_ObjectToWorld, float4( ase_vertexNormal, 0 ) ).xyz;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult74 = dot( objToWorldDir73 , ase_worldViewDir );
			float scale107_g1 = ( _WaveStrength * saturate( ( abs( dotResult74 ) / _WaveDistanceAttenuation ) ) );
			float3 localPerturbNormal107_g1 = PerturbNormal107_g1( surf_pos107_g1 , surf_norm107_g1 , height107_g1 , scale107_g1 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentDir42_g1 = mul( ase_worldToTangent, localPerturbNormal107_g1);
			o.Normal = worldToTangentDir42_g1;
			float4 ase_screenPos100 = i.screenPosition100;
			float4 ase_screenPosNorm100 = ase_screenPos100 / ase_screenPos100.w;
			ase_screenPosNorm100.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm100.z : ase_screenPosNorm100.z * 0.5 + 0.5;
			float screenDepth100 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm100.xy ));
			float distanceDepth100 = saturate( abs( ( screenDepth100 - LinearEyeDepth( ase_screenPosNorm100.z ) ) / ( 10.0 ) ) );
			float4 lerpResult41 = lerp( _Color , _Color2 , distanceDepth100);
			o.Albedo = lerpResult41.rgb;
			o.Smoothness = _Smoothness;
			o.Alpha = lerpResult41.a;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18909
0;1163;1868;917;690.8972;446.5551;2.318737;True;True
Node;AmplifyShaderEditor.CommentaryNode;107;126.5087,-592.6407;Inherit;False;1603.34;1080.796;Wave Height;24;23;36;18;21;14;30;20;37;15;31;27;16;34;38;29;12;35;28;69;39;68;70;66;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;105;2176,384;Inherit;False;1243;629;Wave Strength;10;49;78;48;75;74;73;71;45;72;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;30;362.1712,373.1554;Inherit;False;Property;_Wave2Speed;Wave 2 Speed;12;0;Create;True;0;0;0;False;0;False;1;0.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;14;215.2406,-542.6407;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;21;250.5083,-148.1256;Inherit;False;Property;_Wave1Speed;Wave 1 Speed;6;0;Create;True;0;0;0;False;0;False;1;4.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;18;176.5086,-300.1255;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;23;368.4085,-368.7255;Inherit;False;Property;_Wave1Direction;Wave 1 Direction;5;1;[Header];Create;True;1;Wave1;0;0;False;0;False;0.1,0.2;0.2,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;36;480.0713,152.5554;Inherit;False;Property;_Wave2Direction;Wave 2 Direction;11;1;[Header];Create;True;1;Wave2;0;0;False;0;False;-0.1,0.3;-0.2,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.NormalVertexDataNode;71;2224,560;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;73;2480,560;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;665.5083,-333.1255;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;72;2224,736;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;777.171,188.1553;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;479.9407,-478.1408;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;74;2736,560;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;823.171,56.1553;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;711.5083,-465.1255;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;27;563.748,-171.4577;Inherit;False;Property;_Wave1Scale;Wave 1 Scale;7;0;Create;True;0;0;0;False;0;False;1;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;675.4108,349.8232;Inherit;False;Property;_Wave2Scale;Wave 2 Scale;13;0;Create;True;0;0;0;False;0;False;1;0.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;35;1065.604,52.14011;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;12;892.9406,-447.1407;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;910.4789,-309.2593;Inherit;False;Property;_Wave1Strength;Wave 1 Strength;8;0;Create;True;0;0;0;False;0;False;1;3.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;1040.142,293.0212;Inherit;False;Property;_Wave2Strength;Wave 2 Strength;14;0;Create;True;0;0;0;False;0;False;1;0.53;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;75;2864,560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;106;2336,-1104;Inherit;False;1198;738.7578;Color/Alpha;6;41;1;40;100;91;101;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;45;2224,896;Inherit;False;Property;_WaveDistanceAttenuation;Wave Distance Attenuation;4;1;[Gamma];Create;True;0;0;0;False;0;False;0.1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;1011.241,-224.4178;Inherit;False;Property;_Wave1Curve;Wave 1 Curve;9;0;Create;True;0;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;1286.542,166.6212;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;1057.204,-36.99858;Inherit;False;Property;_Wave2Curve;Wave 2 Curve;10;0;Create;True;0;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;1352.879,-450.6595;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;48;2992,560;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;91;2384,-672;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;70;1334.322,-253.0303;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;100;2608,-672;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;78;3120,560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;66;1179.241,-482.4177;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;2608,-1056;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;0;False;0;False;0,0.4166667,1,0.5019608;0.2830659,0.5292708,0.706,0.2470588;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;40;2608,-864;Inherit;False;Property;_Color2;Color2;1;0;Create;True;0;0;0;False;0;False;0,0.4166667,1,0.5019608;0.1703658,0.2634561,0.5659999,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;2224,432;Inherit;False;Property;_WaveStrength;Wave Strength;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;41;3120,-672;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;1575.849,-457.8923;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;3248,432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;101;3376,-544;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;11;3920,-528;Inherit;False;Property;_Smoothness;Smoothness;2;0;Create;True;0;0;0;False;0;False;1;0.95;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;24;3507.38,263.9193;Inherit;False;Normal From Height;-1;;1;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;1;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4595.806,-221.1395;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;ProcedualWater;False;False;False;False;False;False;True;False;True;False;True;True;False;False;True;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;73;0;71;0
WireConnection;20;0;23;0
WireConnection;20;1;21;0
WireConnection;20;2;18;0
WireConnection;37;0;36;0
WireConnection;37;1;30;0
WireConnection;37;2;18;0
WireConnection;15;0;14;1
WireConnection;15;1;14;3
WireConnection;74;0;73;0
WireConnection;74;1;72;0
WireConnection;34;0;15;0
WireConnection;34;1;37;0
WireConnection;16;0;15;0
WireConnection;16;1;20;0
WireConnection;35;0;34;0
WireConnection;35;1;31;0
WireConnection;12;0;16;0
WireConnection;12;1;27;0
WireConnection;75;0;74;0
WireConnection;39;0;35;0
WireConnection;39;1;38;0
WireConnection;28;0;12;0
WireConnection;28;1;29;0
WireConnection;48;0;75;0
WireConnection;48;1;45;0
WireConnection;70;0;39;0
WireConnection;70;1;69;0
WireConnection;100;1;91;0
WireConnection;78;0;48;0
WireConnection;66;0;28;0
WireConnection;66;1;68;0
WireConnection;41;0;1;0
WireConnection;41;1;40;0
WireConnection;41;2;100;0
WireConnection;26;0;66;0
WireConnection;26;1;70;0
WireConnection;49;0;25;0
WireConnection;49;1;78;0
WireConnection;101;0;41;0
WireConnection;24;20;26;0
WireConnection;24;110;49;0
WireConnection;0;0;41;0
WireConnection;0;1;24;40
WireConnection;0;4;11;0
WireConnection;0;9;101;3
ASEEND*/
//CHKSM=6900F3C728F1FB9350CED50D6898A555333AF2DF