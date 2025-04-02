// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/SH_Ice"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tint("Tint", Color) = (1, 1, 1, 1)
        
        [NoScaleOffset]
        _AmbientTex("Ambient Texture", 2D) = "white"{}
        _AmbientStrength("Ambient Strength", Range(0, 1)) = 0.05
        _AmbientOffset("Ambient Offset", Range(-5, 5)) = 0.05
    } 
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "PreviewType" = "Plane"
        }
        LOD 100

        Pass
        {
            ZWrite Off
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 screenuv: TEXCOORD1;
                float3 viewDir : TEXCOORD3;
                float3 normal: TEXCOORD4;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _AmbientTex;
            float4 _Tint;
            float _AmbientStrength;
            float _AmbientOffset;

            // globals set by the Camera 
            uniform sampler2D _GlobalRefractionTex;
            uniform float _GlobalVisibilty;
            uniform float _GlobalRefractionMag;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                
                o.screenuv = ((o.vertex.xy / o.vertex.w) + 1) * 0.5;
                
                o.normal = UnityObjectToWorldNormal(v.normal);
                
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; // Transform from object to world space
                o.viewDir = normalize(_WorldSpaceCameraPos - worldPos); // Calculate normalized view direction
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture and tint
                float4 color = tex2D(_MainTex, i.uv) * _Tint;

                // sample the render texture from our reflective camera
                // so flip the vertical UV coordinate too
                if (_ProjectionParams.x < 0)
                     i.screenuv.y = 1 - i.screenuv.y;
                
                float2 flippedYScreenUV = i.screenuv;// float2(i.screenuv.x, 1-i.screenuv.y);
                //return float4(flippedYScreenUV, 0, 1);
                float4 refl = tex2D(_GlobalRefractionTex, flippedYScreenUV + i.normal * _GlobalRefractionMag * 0.1);
                //return refl;

                // want to calculate the inner texture FX
                float3 ambientOffset = i.viewDir * _AmbientOffset;
                float3 ambientColor = tex2D(_AmbientTex, i.uv * ambientOffset) * _AmbientStrength;

                // calc final color
                color.rgb = (color.rgb + ambientColor.rgb) * (1.0-refl.a * _GlobalVisibilty) + refl.rgb * refl.a * _GlobalVisibilty;
                
                return color;
            }
            ENDCG
        }
    }
}
