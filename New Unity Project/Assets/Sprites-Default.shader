// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Sprites/Default"
{
	Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap("Pixel snap", Float) = 0
    }
 
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }
 
        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha
 
 
        //-----add--һ�������Pass��Ⱦͨ������������Ҫ������ʱ��ץȡ��Ļ�����ݻ��Ƶ�һ��texture��ɻ���AlphaBlend��
        GrabPass
        {
            "_MyGrabTex"
        }
        //---------
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ PIXELSNAP_ON
            #include "UnityCG.cginc"
 
            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
				//�������꼯��
                float2 texcoord : TEXCOORD0;
            };
 
            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color : COLOR;			
                float2 texcoord  : TEXCOORD0;
            };
 
            fixed4 _Color;
 
            //------------add
            float _Radius;
            float _Angle;
            sampler2D _MyGrabTex;
            //float2 swirl(float2 uv);
            float2 swirl(float2 uv)
            {
                //�ȼ�ȥ��ͼ���ĵ����������,�����Ƿ�����ת���� 
                uv -= float2(0.5, 0.5);
 
                //���㵱ǰ���������ĵ�ľ��롣 
                float dist = length(uv);
 
                //�������ת�İٷֱ� 
                float percent = (_Radius - dist) / _Radius;
 
                if (percent < 1.0 && percent >= 0.0)
                {
                    //ͨ��sin,cos���������ת���λ�á� 
                    float theta = percent * percent * _Angle * 8.0;
                    float s = sin(theta);
                    float c = cos(theta);
                    //uv = float2(dot(uv, float2(c, -s)), dot(uv, float2(s, c))); 

                    uv = float2(uv.x*c - uv.y*s, uv.x*s + uv.y*c);
                }
 
                //�ټ�����ͼ���ĵ���������꣬��������ȷ�� 
                uv += float2(0.5, 0.5);
 
                return uv;
            }
            //---------------
 
            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color * _Color;
                #ifdef PIXELSNAP_ON
                OUT.vertex = UnityPixelSnap(OUT.vertex);
                #endif
 
                return OUT;
            }
 
            sampler2D _MainTex;
            sampler2D _AlphaTex;
            float _AlphaSplitEnabled;
 
            fixed4 SampleSpriteTexture(float2 uv)
            {
                fixed4 color = tex2D(_MainTex, uv);
 

        #if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
                if (_AlphaSplitEnabled)
                    color.a = tex2D(_AlphaTex, uv).r;
        #endif //UNITY_TEXTURE_ALPHASPLIT_ALLOWED
 
                return color;
            }
 
            fixed4 frag(v2f IN) : SV_Target
            {
                //---add
				//���¸��������긳ֵ
                IN.texcoord = swirl(IN.texcoord);
                //--------
 
                fixed4 c = SampleSpriteTexture(IN.texcoord) * IN.color;
                c.rgb *= c.a;
                return c;
            }
            ENDCG
        }
    }
}
