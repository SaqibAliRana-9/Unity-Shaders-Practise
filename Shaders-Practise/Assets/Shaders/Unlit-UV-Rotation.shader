Shader "Unlit/Unlit-IntrinsicOps"
{
   Properties
    {
        
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color Tint",Color)=(1,1,1,1)
        _UVOffset("UV_Offset",Range(0.0,1.0))=0
        _Rotation("Rotation",Range(0,360))=0

    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Rotation;
            float _UVOffset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            void Unity_Rotate_Degrees_float
            (
                float2 UV,
                float Rotation,
                out float2 Out
            )
            {
                Rotation = Rotation * (UNITY_PI/180.0f);
                //UV -= _UVOffset;
                float s = sin(Rotation);
                float c = cos(Rotation);
                float2x2 rMatrix = float2x2(c, s, s, c);
                rMatrix *= _UVOffset;
                rMatrix += _UVOffset;
                rMatrix = rMatrix * 2 - 1;
                UV.xy = mul(UV.yx, rMatrix);
                UV += _UVOffset;
                Out = UV;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv= i.uv - _UVOffset;

                float Rotation=_Rotation;
                float2 UV=0;


                Unity_Rotate_Degrees_float(uv, Rotation, UV);
                

                float4 col = tex2D(_MainTex,UV) * _Color;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
