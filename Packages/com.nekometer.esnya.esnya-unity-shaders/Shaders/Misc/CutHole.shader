// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EsnyaShaders/CutHole"
{
	Properties
	{
		_StencilID("Stencil ID", Int) = 3
		_StencilReadMask("Stencil Read Mask", Int) = 3
		_StencilWriteMask("Stencil Write Mask", Int) = 3

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="AlphaTest+100" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Front
		ColorMask 0
		ZWrite On
		ZTest Always
		Stencil
		{
			Ref [_StencilID]
			ReadMask [_StencilWriteMask]
			WriteMask [_StencilReadMask]
			Comp Equal
			Pass Zero
			Fail Keep
			ZFail Keep
		}
		
		UsePass "Hidden/EsnyaShaders/CutHole/StencilWriter/Unlit"

		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform int _StencilID;
			uniform int _StencilWriteMask;
			uniform int _StencilReadMask;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				
				
				finalColor = fixed4(1,1,1,1);
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
0;1097;1715;982;1190.5;346;1;True;False
Node;AmplifyShaderEditor.IntNode;4;-450.5,-141;Inherit;False;Property;_StencilID;Stencil ID;1;0;Create;True;0;0;0;True;0;False;3;3;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;5;-450.5,115;Inherit;False;Property;_StencilWriteMask;Stencil Write Mask;3;0;Create;True;0;0;0;True;0;False;3;3;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;6;-450.5,-13;Inherit;False;Property;_StencilReadMask;Stencil Read Mask;2;0;Create;True;0;0;0;True;0;False;3;3;False;0;1;INT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;True;-1;2;ASEMaterialInspector;100;1;EsnyaShaders/CutHole;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;1;False;-1;True;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;True;True;True;255;True;4;255;True;5;255;True;6;5;False;-1;2;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;2;RenderType=Opaque=RenderType;Queue=AlphaTest=Queue=100;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;1;Above;Hidden/EsnyaShaders/CutHole/StencilWriter/Unlit;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
ASEEND*/
//CHKSM=DC045588AD53E89289A957A083F10AC7232FDD57