// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EsnyaShaders/EmissiveDisplay"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_EmissionIntensityy("Emission Intensityy", Float) = 2
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		[NoScaleOffset]_MatrixMask("MatrixMask", 2D) = "white" {}
		_PixelsPerUV("Pixels Per UV", Vector) = (1920,1080,0,0)
		[Toggle(_PENTILE_ON)] _Pentile("Pentile", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Int) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull [_CullMode]
		CGPROGRAM
		#pragma target 3.0
		#pragma shader_feature_local _PENTILE_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform int _CullMode;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float2 _PixelsPerUV;
		uniform sampler2D _MatrixMask;
		uniform float _EmissionIntensityy;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color6 = IsGammaSpace() ? float4(0.001,0.001,0.001,1) : float4(7.739938E-05,7.739938E-05,7.739938E-05,1);
			o.Albedo = color6.rgb;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float3 temp_output_5_0 = (tex2D( _MainTex, ( floor( ( uv_MainTex * _PixelsPerUV ) ) / _PixelsPerUV ) )).rgb;
			float2 temp_output_34_0 = ( _PixelsPerUV * 0.5 );
			#ifdef _PENTILE_ON
				float3 staticSwitch19 = ( ( temp_output_5_0 * float3( 0,1,0 ) ) + ( (tex2D( _MainTex, ( floor( ( ( uv_MainTex * temp_output_34_0 ) + float2( 0.25,0.25 ) ) ) / temp_output_34_0 ) )).rgb * float3( 1,0,1 ) ) );
			#else
				float3 staticSwitch19 = temp_output_5_0;
			#endif
			float2 uv_TexCoord13 = i.uv_texcoord * _PixelsPerUV;
			o.Emission = ( staticSwitch19 * (tex2D( _MatrixMask, uv_TexCoord13 )).rgb * _EmissionIntensityy );
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18934
0;1111;1507;968;1558.527;-561.5987;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;33;-1423.173,871.271;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;12;-1408,640;Inherit;False;Property;_PixelsPerUV;Pixels Per UV;4;0;Create;True;0;0;0;False;0;False;1920,1080;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;32;-1392,1072;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-1135.173,888.8711;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-1248,384;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1168,1072;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-1071.527,1182.599;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.25,0.25;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1024,384;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FloorOpNode;30;-1040,1072;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FloorOpNode;17;-896,384;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;31;-912,1072;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;18;-768,384;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;4;-512,384;Inherit;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;20;-512,1024;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;4;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;5;-224,384;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;21;-224,1024;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-1152,640;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;24.2,847.2;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-32,1008;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;192,848;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;9;-512,576;Inherit;True;Property;_MatrixMask;MatrixMask;3;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;f0eff6ad42445df4eb35ef7192631f47;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;10;-224,576;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-208,672;Inherit;False;Property;_EmissionIntensityy;Emission Intensityy;1;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;19;371.1,762.3;Inherit;False;Property;_Pentile;Pentile;5;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;144,384;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;1;-512,32;Inherit;False;Property;_CullMode;Cull Mode;6;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;3;False;0;1;INT;0
Node;AmplifyShaderEditor.ColorNode;6;0,-128;Inherit;False;Constant;_Color0;Color 0;3;0;Create;True;0;0;0;False;0;False;0.001,0.001,0.001,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2;-512,128;Inherit;False;Property;_Smoothness;Smoothness;2;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;379,-30;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;EsnyaShaders/EmissiveDisplay;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;34;0;12;0
WireConnection;34;1;33;0
WireConnection;29;0;32;0
WireConnection;29;1;34;0
WireConnection;35;0;29;0
WireConnection;16;0;15;0
WireConnection;16;1;12;0
WireConnection;30;0;35;0
WireConnection;17;0;16;0
WireConnection;31;0;30;0
WireConnection;31;1;34;0
WireConnection;18;0;17;0
WireConnection;18;1;12;0
WireConnection;4;1;18;0
WireConnection;20;1;31;0
WireConnection;5;0;4;0
WireConnection;21;0;20;0
WireConnection;13;0;12;0
WireConnection;28;0;5;0
WireConnection;26;0;21;0
WireConnection;27;0;28;0
WireConnection;27;1;26;0
WireConnection;9;1;13;0
WireConnection;10;0;9;0
WireConnection;19;1;5;0
WireConnection;19;0;27;0
WireConnection;7;0;19;0
WireConnection;7;1;10;0
WireConnection;7;2;11;0
WireConnection;0;0;6;0
WireConnection;0;2;7;0
WireConnection;0;4;2;0
ASEEND*/
//CHKSM=6A41AEE8F7799E3E862B758C9BB5DCC0DEBEA000