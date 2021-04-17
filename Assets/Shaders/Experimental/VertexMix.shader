// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EsnyaShaders/Experimental/VertexMix"
{
	Properties
	{
		[SingleLineTexture]_MainTex("Albedo Transparency", 2DArray) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset][Normal][SingleLineTexture]_BumpMap("Normal", 2DArray) = "bump" {}
		[VisibleIf(_NORMALMAP)]_BumpScale("Scale", Float) = 1
		[NoScaleOffset][SingleLineTexture]_MetallicGlossMap("Metallic Occlusion Height Smoothness", 2DArray) = "white" {}
		_HeightScale("Height Scale", Range( 0.005 , 0.08)) = 0.02
		[NoScaleOffset][SingleLineTexture]_EmissionMap("Emission", 2DArray) = "white" {}
		[HDR]_EmissionColor("Color", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D_ARRAY(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D_ARRAY(tex,samplertex,coord) tex2DArray(tex,coord)
		#endif//ASE Sampling Macros

		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float4 vertexColor : COLOR;
		};

		UNITY_DECLARE_TEX2DARRAY_NOSAMPLER(_BumpMap);
		UNITY_DECLARE_TEX2DARRAY_NOSAMPLER(_MainTex);
		uniform float4 _MainTex_ST;
		UNITY_DECLARE_TEX2DARRAY_NOSAMPLER(_MetallicGlossMap);
		SamplerState sampler_MetallicGlossMap;
		uniform float _HeightScale;
		SamplerState sampler_BumpMap;
		uniform float _BumpScale;
		SamplerState sampler_MainTex;
		uniform float4 _Color;
		UNITY_DECLARE_TEX2DARRAY_NOSAMPLER(_EmissionMap);
		SamplerState sampler_EmissionMap;
		uniform float4 _EmissionColor;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float temp_output_48_0_g28 = 0.0;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 Offset22_g28 = ( ( SAMPLE_TEXTURE2D_ARRAY( _MetallicGlossMap, sampler_MetallicGlossMap, float3(uv_MainTex,temp_output_48_0_g28) ).g - 1 ) * ase_worldViewDir.xy * _HeightScale ) + uv_MainTex;
			float temp_output_289_0 = ( i.vertexColor.r + i.vertexColor.g + i.vertexColor.b );
			float temp_output_32_0_g28 = max( ( 1.0 - temp_output_289_0 ) , 0.0 );
			float temp_output_48_0_g26 = 1.0;
			float2 Offset22_g26 = ( ( SAMPLE_TEXTURE2D_ARRAY( _MetallicGlossMap, sampler_MetallicGlossMap, float3(uv_MainTex,temp_output_48_0_g26) ).g - 1 ) * ase_worldViewDir.xy * _HeightScale ) + uv_MainTex;
			float4 break327 = ( i.vertexColor / max( temp_output_289_0 , 1.0 ) );
			float temp_output_32_0_g26 = break327.r;
			float temp_output_48_0_g29 = 2.0;
			float2 Offset22_g29 = ( ( SAMPLE_TEXTURE2D_ARRAY( _MetallicGlossMap, sampler_MetallicGlossMap, float3(uv_MainTex,temp_output_48_0_g29) ).g - 1 ) * ase_worldViewDir.xy * _HeightScale ) + uv_MainTex;
			float temp_output_32_0_g29 = break327.g;
			float temp_output_48_0_g27 = 3.0;
			float2 Offset22_g27 = ( ( SAMPLE_TEXTURE2D_ARRAY( _MetallicGlossMap, sampler_MetallicGlossMap, float3(uv_MainTex,temp_output_48_0_g27) ).g - 1 ) * ase_worldViewDir.xy * _HeightScale ) + uv_MainTex;
			float temp_output_32_0_g27 = break327.b;
			o.Normal = ( ( UnpackScaleNormal( SAMPLE_TEXTURE2D_ARRAY( _BumpMap, sampler_BumpMap, float3(Offset22_g28,temp_output_48_0_g28) ), _BumpScale ) * temp_output_32_0_g28 ) + ( UnpackScaleNormal( SAMPLE_TEXTURE2D_ARRAY( _BumpMap, sampler_BumpMap, float3(Offset22_g26,temp_output_48_0_g26) ), _BumpScale ) * temp_output_32_0_g26 ) + ( UnpackScaleNormal( SAMPLE_TEXTURE2D_ARRAY( _BumpMap, sampler_BumpMap, float3(Offset22_g29,temp_output_48_0_g29) ), _BumpScale ) * temp_output_32_0_g29 ) + ( UnpackScaleNormal( SAMPLE_TEXTURE2D_ARRAY( _BumpMap, sampler_BumpMap, float3(Offset22_g27,temp_output_48_0_g27) ), _BumpScale ) * temp_output_32_0_g27 ) );
			float4 temp_output_31_0_g28 = ( SAMPLE_TEXTURE2D_ARRAY( _MainTex, sampler_MainTex, float3(Offset22_g28,temp_output_48_0_g28) ) * _Color * temp_output_32_0_g28 );
			float4 temp_output_31_0_g26 = ( SAMPLE_TEXTURE2D_ARRAY( _MainTex, sampler_MainTex, float3(Offset22_g26,temp_output_48_0_g26) ) * _Color * temp_output_32_0_g26 );
			float4 temp_output_31_0_g29 = ( SAMPLE_TEXTURE2D_ARRAY( _MainTex, sampler_MainTex, float3(Offset22_g29,temp_output_48_0_g29) ) * _Color * temp_output_32_0_g29 );
			float4 temp_output_31_0_g27 = ( SAMPLE_TEXTURE2D_ARRAY( _MainTex, sampler_MainTex, float3(Offset22_g27,temp_output_48_0_g27) ) * _Color * temp_output_32_0_g27 );
			o.Albedo = ( (temp_output_31_0_g28).rgb + (temp_output_31_0_g26).rgb + (temp_output_31_0_g29).rgb + (temp_output_31_0_g27).rgb );
			o.Emission = ( (( SAMPLE_TEXTURE2D_ARRAY( _EmissionMap, sampler_EmissionMap, float3(Offset22_g28,temp_output_48_0_g28) ) * _EmissionColor * temp_output_32_0_g28 )).rgb + (( SAMPLE_TEXTURE2D_ARRAY( _EmissionMap, sampler_EmissionMap, float3(Offset22_g26,temp_output_48_0_g26) ) * _EmissionColor * temp_output_32_0_g26 )).rgb + (( SAMPLE_TEXTURE2D_ARRAY( _EmissionMap, sampler_EmissionMap, float3(Offset22_g29,temp_output_48_0_g29) ) * _EmissionColor * temp_output_32_0_g29 )).rgb + (( SAMPLE_TEXTURE2D_ARRAY( _EmissionMap, sampler_EmissionMap, float3(Offset22_g27,temp_output_48_0_g27) ) * _EmissionColor * temp_output_32_0_g27 )).rgb );
			float4 temp_output_41_0_g28 = ( SAMPLE_TEXTURE2D_ARRAY( _MetallicGlossMap, sampler_MetallicGlossMap, float3(Offset22_g28,temp_output_48_0_g28) ) * temp_output_32_0_g28 );
			float4 temp_output_41_0_g26 = ( SAMPLE_TEXTURE2D_ARRAY( _MetallicGlossMap, sampler_MetallicGlossMap, float3(Offset22_g26,temp_output_48_0_g26) ) * temp_output_32_0_g26 );
			float4 temp_output_41_0_g29 = ( SAMPLE_TEXTURE2D_ARRAY( _MetallicGlossMap, sampler_MetallicGlossMap, float3(Offset22_g29,temp_output_48_0_g29) ) * temp_output_32_0_g29 );
			float4 temp_output_41_0_g27 = ( SAMPLE_TEXTURE2D_ARRAY( _MetallicGlossMap, sampler_MetallicGlossMap, float3(Offset22_g27,temp_output_48_0_g27) ) * temp_output_32_0_g27 );
			float4 break282 = ( temp_output_41_0_g28 + temp_output_41_0_g26 + temp_output_41_0_g29 + temp_output_41_0_g27 );
			o.Metallic = break282;
			o.Smoothness = break282.a;
			o.Occlusion = break282.b;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
0;1346;2168;734;2867.88;230.6992;2.350538;True;True
Node;AmplifyShaderEditor.VertexColorNode;219;-1360,1232;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;326;-1024,1568;Inherit;False;Constant;_Float4;Float 4;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;289;-1024,1408;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;325;-848,1504;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;290;-288,1552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;324;-768,1216;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;259;-1024,704;Inherit;False;Property;_EmissionColor;Color;7;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;11;-1024,512;Inherit;True;Property;_EmissionMap;Emission;6;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;False;0;False;None;None;False;white;LockedToTexture2DArray;Texture2DArray;-1;0;2;SAMPLER2DARRAY;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.BreakToComponentsNode;327;-607.0309,1365.066;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;8;-1024,432;Inherit;False;Property;_BumpScale;Scale;3;0;Create;False;0;0;0;False;1;VisibleIf(_NORMALMAP);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;322;-496,1104;Inherit;False;Constant;_Float2;Float 2;8;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;258;-1024,64;Inherit;False;Property;_Color;Color;1;0;Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;291;-288,1072;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1024,880;Inherit;True;Property;_MetallicGlossMap;Metallic Occlusion Height Smoothness;4;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;False;0;False;None;None;False;white;LockedToTexture2DArray;Texture2DArray;-1;0;2;SAMPLER2DARRAY;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;1;-1024,-128;Inherit;True;Property;_MainTex;Albedo Transparency;0;1;[SingleLineTexture];Create;False;1;Base;0;0;False;0;False;None;None;False;white;LockedToTexture2DArray;Texture2DArray;-1;0;2;SAMPLER2DARRAY;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1024,240;Inherit;True;Property;_BumpMap;Normal;2;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;False;0;False;None;None;False;bump;LockedToTexture2DArray;Texture2DArray;-1;0;2;SAMPLER2DARRAY;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;323;-432,128;Inherit;False;Constant;_Float3;Float 3;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;296;-455.0447,495.0925;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;321;-496,768;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1024,1072;Inherit;False;Property;_HeightScale;Height Scale;5;0;Create;True;0;0;0;False;0;False;0.02;0.02;0.005;0.08;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;320;-128,960;Inherit;False;VertexMixCore;-1;;27;365f825d67dfe1242b4dfb0c206d5d03;0;14;1;SAMPLER2DARRAY;0;False;20;SAMPLERSTATE;0;False;5;COLOR;1,1,1,1;False;2;SAMPLER2DARRAY;0;False;19;SAMPLERSTATE;0;False;4;FLOAT;1;False;3;SAMPLER2DARRAY;0;False;18;SAMPLERSTATE;0;False;7;COLOR;0,0,0,0;False;12;SAMPLER2DARRAY;0;False;17;SAMPLERSTATE;0;False;25;FLOAT;0.05;False;48;FLOAT;0;False;32;FLOAT;1;False;8;FLOAT3;0;FLOAT3;37;FLOAT3;40;FLOAT;43;FLOAT;44;FLOAT;45;FLOAT;35;COLOR;46
Node;AmplifyShaderEditor.FunctionNode;319;-128,608;Inherit;False;VertexMixCore;-1;;29;365f825d67dfe1242b4dfb0c206d5d03;0;14;1;SAMPLER2DARRAY;0;False;20;SAMPLERSTATE;0;False;5;COLOR;1,1,1,1;False;2;SAMPLER2DARRAY;0;False;19;SAMPLERSTATE;0;False;4;FLOAT;1;False;3;SAMPLER2DARRAY;0;False;18;SAMPLERSTATE;0;False;7;COLOR;0,0,0,0;False;12;SAMPLER2DARRAY;0;False;17;SAMPLERSTATE;0;False;25;FLOAT;0.05;False;48;FLOAT;0;False;32;FLOAT;1;False;8;FLOAT3;0;FLOAT3;37;FLOAT3;40;FLOAT;43;FLOAT;44;FLOAT;45;FLOAT;35;COLOR;46
Node;AmplifyShaderEditor.FunctionNode;317;-128,-128;Inherit;False;VertexMixCore;-1;;28;365f825d67dfe1242b4dfb0c206d5d03;0;14;1;SAMPLER2DARRAY;0;False;20;SAMPLERSTATE;0;False;5;COLOR;1,1,1,1;False;2;SAMPLER2DARRAY;0;False;19;SAMPLERSTATE;0;False;4;FLOAT;1;False;3;SAMPLER2DARRAY;0;False;18;SAMPLERSTATE;0;False;7;COLOR;0,0,0,0;False;12;SAMPLER2DARRAY;0;False;17;SAMPLERSTATE;0;False;25;FLOAT;0.05;False;48;FLOAT;0;False;32;FLOAT;1;False;8;FLOAT3;0;FLOAT3;37;FLOAT3;40;FLOAT;43;FLOAT;44;FLOAT;45;FLOAT;35;COLOR;46
Node;AmplifyShaderEditor.FunctionNode;318;-128,256;Inherit;False;VertexMixCore;-1;;26;365f825d67dfe1242b4dfb0c206d5d03;0;14;1;SAMPLER2DARRAY;0;False;20;SAMPLERSTATE;0;False;5;COLOR;1,1,1,1;False;2;SAMPLER2DARRAY;0;False;19;SAMPLERSTATE;0;False;4;FLOAT;1;False;3;SAMPLER2DARRAY;0;False;18;SAMPLERSTATE;0;False;7;COLOR;0,0,0,0;False;12;SAMPLER2DARRAY;0;False;17;SAMPLERSTATE;0;False;25;FLOAT;0.05;False;48;FLOAT;0;False;32;FLOAT;1;False;8;FLOAT3;0;FLOAT3;37;FLOAT3;40;FLOAT;43;FLOAT;44;FLOAT;45;FLOAT;35;COLOR;46
Node;AmplifyShaderEditor.SimpleAddOpNode;281;400,960;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;279;512,256;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;282;544,960;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;278;512,-128;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;280;512,640;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;930.9376,-42.41655;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;EsnyaShaders/Experimental/VertexMix;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;289;0;219;1
WireConnection;289;1;219;2
WireConnection;289;2;219;3
WireConnection;325;0;289;0
WireConnection;325;1;326;0
WireConnection;290;0;289;0
WireConnection;324;0;219;0
WireConnection;324;1;325;0
WireConnection;327;0;324;0
WireConnection;291;0;290;0
WireConnection;320;1;1;0
WireConnection;320;20;1;1
WireConnection;320;5;258;0
WireConnection;320;2;2;0
WireConnection;320;19;2;1
WireConnection;320;4;8;0
WireConnection;320;3;11;0
WireConnection;320;18;11;1
WireConnection;320;7;259;0
WireConnection;320;12;3;0
WireConnection;320;17;3;1
WireConnection;320;25;17;0
WireConnection;320;48;322;0
WireConnection;320;32;327;2
WireConnection;319;1;1;0
WireConnection;319;20;1;1
WireConnection;319;5;258;0
WireConnection;319;2;2;0
WireConnection;319;19;2;1
WireConnection;319;4;8;0
WireConnection;319;3;11;0
WireConnection;319;18;11;1
WireConnection;319;7;259;0
WireConnection;319;12;3;0
WireConnection;319;17;3;1
WireConnection;319;25;17;0
WireConnection;319;48;321;0
WireConnection;319;32;327;1
WireConnection;317;1;1;0
WireConnection;317;20;1;1
WireConnection;317;5;258;0
WireConnection;317;2;2;0
WireConnection;317;19;2;1
WireConnection;317;4;8;0
WireConnection;317;3;11;0
WireConnection;317;18;11;1
WireConnection;317;7;259;0
WireConnection;317;12;3;0
WireConnection;317;17;3;1
WireConnection;317;25;17;0
WireConnection;317;48;323;0
WireConnection;317;32;291;0
WireConnection;318;1;1;0
WireConnection;318;20;1;1
WireConnection;318;5;258;0
WireConnection;318;2;2;0
WireConnection;318;19;2;1
WireConnection;318;4;8;0
WireConnection;318;3;11;0
WireConnection;318;18;11;1
WireConnection;318;7;259;0
WireConnection;318;12;3;0
WireConnection;318;17;3;1
WireConnection;318;25;17;0
WireConnection;318;48;296;0
WireConnection;318;32;327;0
WireConnection;281;0;317;46
WireConnection;281;1;318;46
WireConnection;281;2;319;46
WireConnection;281;3;320;46
WireConnection;279;0;317;37
WireConnection;279;1;318;37
WireConnection;279;2;319;37
WireConnection;279;3;320;37
WireConnection;282;0;281;0
WireConnection;278;0;317;0
WireConnection;278;1;318;0
WireConnection;278;2;319;0
WireConnection;278;3;320;0
WireConnection;280;0;317;40
WireConnection;280;1;318;40
WireConnection;280;2;319;40
WireConnection;280;3;320;40
WireConnection;0;0;278;0
WireConnection;0;1;279;0
WireConnection;0;2;280;0
WireConnection;0;3;282;0
WireConnection;0;4;282;3
WireConnection;0;5;282;2
ASEEND*/
//CHKSM=ED6C7FCC2BC4C316C6762D98A676F64BF9F9E622