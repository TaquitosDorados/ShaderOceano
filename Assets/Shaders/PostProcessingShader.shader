// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PostProcessingShader"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_NearColor("NearColor", Color) = (0,0,0,0)
		_MidColor("MidColor", Color) = (0.4622642,0.4622642,0.4622642,0.4980392)
		_FarColor("FarColor", Color) = (1,1,1,1)
		_MidPoint("MidPoint", Range( 0 , 1)) = 0.5
		[Toggle]_MultiplyColor("MultiplyColor", Float) = 0

	}

	SubShader
	{
		LOD 0

		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{ 
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				float4 ase_texcoord4 : TEXCOORD4;
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float _MultiplyColor;
			uniform float4 _NearColor;
			uniform float4 _MidColor;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _MidPoint;
			uniform float4 _FarColor;


			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float4 screenPos = i.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 OriginalUvs6 = (ase_screenPosNorm).xy;
				float2 Refraction8 = OriginalUvs6;
				float4 OriginalColor13 = tex2D( _MainTex, Refraction8 );
				float4 temp_output_13_0_g1 = _MidColor;
				float eyeDepth14 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float smoothstepResult16 = smoothstep( _ProjectionParams.y , _ProjectionParams.z , eyeDepth14);
				float temp_output_1_0_g3 = 0.0;
				float temp_output_2_0_g1 = _MidPoint;
				float4 lerpResult16_g1 = lerp( _NearColor , temp_output_13_0_g1 , saturate( ( ( saturate( smoothstepResult16 ) - temp_output_1_0_g3 ) / ( temp_output_2_0_g1 - temp_output_1_0_g3 ) ) ));
				float temp_output_1_0_g2 = temp_output_2_0_g1;
				float4 lerpResult17_g1 = lerp( temp_output_13_0_g1 , _FarColor , saturate( ( ( saturate( smoothstepResult16 ) - temp_output_1_0_g2 ) / ( 1.0 - temp_output_1_0_g2 ) ) ));
				float4 lerpResult18_g1 = lerp( lerpResult16_g1 , lerpResult17_g1 , step( temp_output_2_0_g1 , saturate( smoothstepResult16 ) ));
				float4 temp_output_35_0 = lerpResult18_g1;
				float4 lerpResult31 = lerp( OriginalColor13 , (( _MultiplyColor )?( ( OriginalColor13 * temp_output_35_0 ) ):( temp_output_35_0 )) , (temp_output_35_0).a);
				float4 newColor32 = lerpResult31;
				

				finalColor = newColor32;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18934
353.6;73.6;781.2001;463.8;1245.782;378.6854;1.828289;False;False
Node;AmplifyShaderEditor.ScreenPosInputsNode;4;-1191.335,-82.01059;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;5;-995.1979,-71.2141;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-991.5991,15.15821;Inherit;False;OriginalUvs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;7;-1079.771,276.0745;Inherit;False;6;OriginalUvs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-851.2441,268.8769;Inherit;False;Refraction;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-734.2815,-56.81871;Inherit;False;8;Refraction;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;11;-563.3367,-116.2001;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;14;-406.7863,571.1793;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ProjectionParams;15;-406.7865,668.348;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-431.9786,-89.20876;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;16;-172.8614,659.3508;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;20;14.2787,479.4085;Inherit;False;Property;_FarColor;FarColor;2;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;19;16.07799,312.0625;Inherit;False;Property;_MidColor;MidColor;1;0;Create;True;0;0;0;False;0;False;0.4622642,0.4622642,0.4622642,0.4980392;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;18;19.67685,144.7159;Inherit;False;Property;_NearColor;NearColor;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-133.2748,-69.41527;Inherit;False;OriginalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;25;232.6914,237.2079;Inherit;False;Property;_MidPoint;MidPoint;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;17;3.482131,668.3478;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;486.0937,145.7432;Inherit;False;13;OriginalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;35;360.9412,420.1703;Inherit;True;TripleColorLerp;-1;;1;a0483b94711d1284a9a641d45c0893bf;0;5;2;FLOAT;0;False;3;FLOAT;0;False;12;COLOR;0,0,0,0;False;13;COLOR;0,0,0,0;False;14;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;598.5506,274.6936;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;28;781.4803,289.6878;Inherit;False;Property;_MultiplyColor;MultiplyColor;4;0;Create;True;0;0;0;False;0;False;0;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;29;733.4987,517.5999;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;31;1007.893,165.2357;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;1211.815,178.7305;Inherit;False;newColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;460.6037,-77.67075;Inherit;False;32;newColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;725.7288,-80.37057;Float;False;True;-1;2;ASEMaterialInspector;0;2;PostProcessingShader;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;5;0;4;0
WireConnection;6;0;5;0
WireConnection;8;0;7;0
WireConnection;12;0;11;0
WireConnection;12;1;9;0
WireConnection;16;0;14;0
WireConnection;16;1;15;2
WireConnection;16;2;15;3
WireConnection;13;0;12;0
WireConnection;17;0;16;0
WireConnection;35;2;25;0
WireConnection;35;3;17;0
WireConnection;35;12;18;0
WireConnection;35;13;19;0
WireConnection;35;14;20;0
WireConnection;27;0;26;0
WireConnection;27;1;35;0
WireConnection;28;0;35;0
WireConnection;28;1;27;0
WireConnection;29;0;35;0
WireConnection;31;0;26;0
WireConnection;31;1;28;0
WireConnection;31;2;29;0
WireConnection;32;0;31;0
WireConnection;0;0;33;0
ASEEND*/
//CHKSM=FF58FD4623D231622FF0362834E63B798CE6D69B