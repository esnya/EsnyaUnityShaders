Shader "EsnyaShaders/Occluder"
{
	Properties
	{
	}

	SubShader
	{
		Tags{
            "RenderType" = "Opaque"
            "Queue" = "Geometry-1"
            "ForceNoShadowCasting" = "True"
            "IgnoreProjector" = "True"
        }

        Pass {
            ZWrite On
            ColorMask 0

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

            struct appdata {
                float3 pos : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata IN) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.pos = UnityObjectToClipPos(IN.pos);
                return o;
            }

            fixed4 frag (v2f IN) : SV_Target {
                return fixed4(0, 0, 0, 0);
            }
            ENDCG
        }
	}
}
